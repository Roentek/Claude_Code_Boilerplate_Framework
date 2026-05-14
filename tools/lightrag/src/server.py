"""
LightRAGPlus server — integrates cloud backend mirroring into the lightrag-hku
Web UI without modifying the third-party server code.

How it works:
  1. Patches `lightrag.api.lightrag_server.LightRAG` with MirroringLightRAG
     before `create_app` is called, so every embedding the server generates
     is also mirrored to enabled Supabase / Pinecone backends.
  2. Wraps `create_app` to inject two extra endpoints:
       POST /api/plus/insert-media  — image/audio/video → cloud backends only
       GET  /api/plus/status        — backend health summary

Routing contract (from .env):
  Text (PDF, MD, TXT, etc.) → Web UI upload → local LightRAG graph
                                              + cloud mirror if enabled
  Media (image/audio/video) → /api/plus/insert-media → cloud only
                               requires MULTIMODAL_MODE=advanced
                                      + EMBEDDING_PROVIDER=gemini

Usage (replaces start_server.bat's lightrag_server call):
  uv run python src/server.py --port 9621 --working-dir ./rag_storage \\
      --embedding-binding-host https://api.openai.com/v1
"""
import asyncio
import hashlib
import logging
import os
import sys
from pathlib import Path

# tools/lightrag/ must be in path so `src.*` imports resolve
sys.path.insert(0, str(Path(__file__).parent.parent))

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# MirroringLightRAG — wraps the server's embedding_func with backend mirroring
# ---------------------------------------------------------------------------

def _build_mirroring_class(cfg):
    """
    Return (MirroringLightRAG, supabase_adapter, pinecone_adapter).

    MirroringLightRAG is a LightRAG subclass whose __init__ intercepts the
    embedding_func kwarg and wraps it so every batch of embeddings is also
    upserted to enabled cloud backends.

    If no backends are enabled, returns the original LightRAG class unchanged.
    """
    import lightrag
    from lightrag.utils import EmbeddingFunc

    supabase = None
    pinecone_ = None

    if cfg.ENABLE_SUPABASE:
        from src.adapters.supabase_adapter import SupabaseAdapter
        supabase = SupabaseAdapter(cfg)

    if cfg.ENABLE_PINECONE:
        from src.adapters.pinecone_adapter import PineconeAdapter
        pinecone_ = PineconeAdapter(cfg)

    if not supabase and not pinecone_:
        # No backends — pass through unchanged
        return lightrag.LightRAG, None, None

    _sub, _pin = supabase, pinecone_

    class MirroringLightRAG(lightrag.LightRAG):
        """LightRAG that mirrors every embedding batch to cloud backends."""

        def __init__(self, *args, **kwargs):
            orig: EmbeddingFunc | None = kwargs.get("embedding_func")

            if orig:
                async def _mirroring(texts: list[str]):
                    import numpy as np

                    raw = await orig.func(texts)
                    arr = np.array(raw)

                    tasks = []
                    for i, text in enumerate(texts):
                        id_ = hashlib.md5(text.encode()).hexdigest()
                        vec = arr[i].tolist()
                        meta = {"text": text[:500], "content_type": "text"}
                        if _sub:
                            tasks.append(_sub.upsert(id_, vec, meta))
                        if _pin:
                            tasks.append(_pin.upsert(id_, vec, meta))

                    if tasks:
                        results = await asyncio.gather(*tasks, return_exceptions=True)
                        for r in results:
                            if isinstance(r, Exception):
                                logger.warning("Backend mirror error (non-fatal): %s", r)

                    return arr

                kwargs["embedding_func"] = EmbeddingFunc(
                    embedding_dim=orig.embedding_dim,
                    max_token_size=orig.max_token_size,
                    func=_mirroring,
                )

            super().__init__(*args, **kwargs)

    return MirroringLightRAG, supabase, pinecone_


# ---------------------------------------------------------------------------
# Extra routes injected into the lightrag-hku FastAPI app
# ---------------------------------------------------------------------------

def _add_plus_routes(app, cfg, supabase, pinecone_):
    """Inject /api/plus/* endpoints into the existing FastAPI app."""
    from fastapi import File, HTTPException, UploadFile
    from fastapi.responses import JSONResponse

    @app.get("/api/plus/status")
    async def plus_status():
        """Return LightRAGPlus backend configuration and health."""
        info = {
            "embedding_provider": cfg.EMBEDDING_PROVIDER,
            "multimodal_mode": cfg.MULTIMODAL_MODE,
            "supabase_enabled": cfg.ENABLE_SUPABASE,
            "pinecone_enabled": cfg.ENABLE_PINECONE,
        }

        checks = {}
        if supabase:
            try:
                checks["supabase"] = await supabase.health_check()
            except Exception as e:
                checks["supabase"] = f"error: {e}"
        if pinecone_:
            try:
                checks["pinecone"] = await pinecone_.health_check()
            except Exception as e:
                checks["pinecone"] = f"error: {e}"

        return JSONResponse({"status": "ok", "config": info, "health": checks})

    @app.post("/api/plus/insert-media")
    async def insert_media(file: UploadFile = File(...)):
        """
        Upload image, audio, or video to cloud backends (not LightRAG graph).

        Requires:
          MULTIMODAL_MODE=advanced
          EMBEDDING_PROVIDER=gemini
          ENABLE_SUPABASE=true and/or ENABLE_PINECONE=true
        """
        if not supabase and not pinecone_:
            raise HTTPException(
                400,
                "No cloud backends enabled. Set ENABLE_SUPABASE=true or ENABLE_PINECONE=true.",
            )

        if cfg.MULTIMODAL_MODE != "advanced":
            raise HTTPException(
                400,
                "MULTIMODAL_MODE=advanced required for media uploads. "
                "Text files can be uploaded via the normal Web UI.",
            )

        if cfg.EMBEDDING_PROVIDER != "gemini":
            raise HTTPException(
                400,
                "EMBEDDING_PROVIDER=gemini required for multimodal embeddings.",
            )

        ct = (file.content_type or "").lower()
        if ct.startswith("image/"):
            kind = "image"
        elif ct.startswith("audio/"):
            kind = "audio"
        elif ct.startswith("video/"):
            kind = "video"
        else:
            raise HTTPException(
                400,
                f"Unsupported media type '{ct}'. "
                "Use the Web UI upload for text documents (PDF, MD, TXT, etc.).",
            )

        data = await file.read()

        from src.lightrag_plus import LightRAGPlus

        plus = LightRAGPlus.__new__(LightRAGPlus)
        plus.config = cfg
        plus._rag = None
        plus._embedder = LightRAGPlus._build_embedder(cfg)
        plus._supabase = supabase
        plus._pinecone = pinecone_

        try:
            await plus.insert(data, content_type=kind)
            return JSONResponse({
                "status": "ok",
                "content_type": kind,
                "bytes": len(data),
                "filename": file.filename,
            })
        except Exception as e:
            logger.exception("Media insert failed")
            raise HTTPException(500, str(e))


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    from src.config import Config

    cfg = Config()

    import lightrag.api.lightrag_server as _server

    # Patch LightRAG BEFORE create_app — server's local `LightRAG` name
    # is what gets called at line ~1060: `rag = LightRAG(...)`
    mirroring_cls, supabase, pinecone_ = _build_mirroring_class(cfg)
    _server.LightRAG = mirroring_cls

    if supabase or pinecone_:
        logger.info(
            "LightRAGPlus: cloud mirroring active — supabase=%s pinecone=%s",
            cfg.ENABLE_SUPABASE,
            cfg.ENABLE_PINECONE,
        )
    else:
        logger.info("LightRAGPlus: no cloud backends enabled, running as vanilla LightRAG")

    # Wrap create_app to inject /api/plus/* routes after the app is built
    _orig_create_app = _server.create_app

    def _patched_create_app(args):
        app = _orig_create_app(args)
        _add_plus_routes(app, cfg, supabase, pinecone_)
        return app

    _server.create_app = _patched_create_app

    # Delegate to the real main() — it parses sys.argv, sets up uvicorn, etc.
    from lightrag.api.lightrag_server import main as _server_main
    _server_main()


if __name__ == "__main__":
    main()
