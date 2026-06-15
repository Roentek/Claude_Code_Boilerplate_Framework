"""
LightRAG Plus — wraps native LightRAG with optional Gemini multimodal embeddings
and Supabase/Pinecone vector backend mirroring.

LightRAG core is UNTOUCHED. Adapters bolt on after embeddings are generated.
If all adapters are disabled, behaves identically to vanilla LightRAG.

Usage:
    plus = await LightRAGPlus.create()
    await plus.insert("Your document text")
    result = await plus.query("Your question?")

    # Multimodal (requires EMBEDDING_PROVIDER=gemini, MULTIMODAL_MODE=advanced,
    # and at least one remote backend enabled)
    await plus.insert(Path("image.jpg"), content_type="image")
    await plus.insert(Path("audio.mp3"), content_type="audio")
    await plus.insert(Path("video.mp4"), content_type="video")

    # Hybrid query searches LightRAG graph + remote backends
    result = await plus.query("question", mode="hybrid")
    print(result["graph"])   # LightRAG answer
    print(result["remote"])  # vector matches from Supabase/Pinecone
"""
import asyncio
import hashlib
import logging
from pathlib import Path
from typing import Union

from lightrag import LightRAG, QueryParam
from lightrag.utils import EmbeddingFunc

from .config import Config

logger = logging.getLogger(__name__)


class LightRAGPlus:
    def __init__(self, config: Config, _rag: LightRAG, _embedder, _supabase, _pinecone):
        # Private — use LightRAGPlus.create()
        self.config = config
        self._rag = _rag
        self._embedder = _embedder
        self._supabase = _supabase
        self._pinecone = _pinecone

    @classmethod
    async def _preflight(cls, cfg: Config) -> None:
        """Health-check enabled backends before startup. Raises on failure."""
        errors = []

        if cfg.ENABLE_SUPABASE:
            from .adapters.supabase_adapter import SupabaseAdapter
            try:
                ok = await SupabaseAdapter(cfg).health_check()
            except Exception:
                ok = False
            if not ok:
                errors.append(
                    "Supabase table 'lightrag_vectors' missing.\n"
                    "    Run: cd tools/lightrag-plus && uv run python provision.py"
                )

        if cfg.ENABLE_PINECONE:
            from .adapters.pinecone_adapter import PineconeAdapter
            try:
                ok = await PineconeAdapter(cfg).health_check()
            except Exception:
                ok = False
            if not ok:
                errors.append(
                    f"Pinecone index '{cfg.PINECONE_INDEX}' missing.\n"
                    "    Run: cd tools/lightrag-plus && uv run python provision.py"
                )

        if errors:
            raise RuntimeError(
                "Backend preflight failed:\n" +
                "\n".join(f"  • {e}" for e in errors)
            )

    @classmethod
    async def create(
        cls,
        working_dir: str = "./rag_storage",
        config: Config | None = None,
    ) -> "LightRAGPlus":
        """Async factory — initializes LightRAG and all enabled backends."""
        cfg = config or Config()
        await cls._preflight(cfg)
        embedder = cls._build_embedder(cfg)
        supabase = cls._build_supabase(cfg)
        pinecone_ = cls._build_pinecone(cfg)

        embed_func = EmbeddingFunc(
            embedding_dim=cfg.EMBEDDING_DIM,
            max_token_size=8192,
            func=lambda texts: _embed_and_mirror(texts, embedder, supabase, pinecone_),
        )
        llm_func = cls._build_llm_func(cfg)

        rag = LightRAG(working_dir=working_dir, embedding_func=embed_func, llm_model_func=llm_func)
        await rag.initialize_storages()

        return cls(cfg, rag, embedder, supabase, pinecone_)

    # ── Public API ────────────────────────────────────────────────────────────

    async def insert(
        self,
        content: Union[str, Path, bytes],
        content_type: str = "text",
    ) -> None:
        """
        Insert content into LightRAG Plus.

        content_type: "text" | "image" | "audio" | "video"

        simple mode:   non-text content types are rejected with a warning.
        advanced mode: non-text content is embedded as multimodal and pushed
                       to remote backends only (not LightRAG graph).
        """
        if content_type == "text":
            text = content if isinstance(content, str) else Path(content).read_text()
            await self._rag.ainsert(text)
            return

        if self.config.MULTIMODAL_MODE == "simple":
            logger.warning(
                "content_type=%r requires MULTIMODAL_MODE=advanced. Content skipped.",
                content_type,
            )
            return

        if not self._has_remote_backends():
            logger.warning(
                "Advanced multimodal insert requires ENABLE_SUPABASE or ENABLE_PINECONE. "
                "Content skipped."
            )
            return

        data, mime = self._preprocess(content, content_type)
        embedding = await self._embed_multimodal(data, mime)
        id_ = hashlib.md5(data).hexdigest()
        meta = {"content_type": content_type, "mime_type": mime, "text": ""}
        await self._sync_to_remotes(id_, embedding, meta)

    async def query(
        self,
        text: str,
        mode: str = "graph",
        top_k: int = 10,
        lightrag_mode: str = "hybrid",
    ) -> dict:
        """
        Query LightRAG Plus.

        mode:
          "graph"  — LightRAG knowledge graph only (fast, default)
          "hybrid" — LightRAG graph + all enabled remote backends (comprehensive)

        lightrag_mode: passed to LightRAG QueryParam (naive/local/global/hybrid/mix)
        """
        graph_result = await self._rag.aquery(text, param=QueryParam(mode=lightrag_mode))

        if mode == "graph" or not self._has_remote_backends():
            return {"graph": graph_result, "remote": []}

        embedding = await self._embedder.embed_single(text)
        remote_results = await self._search_remotes(embedding, top_k)
        return {"graph": graph_result, "remote": remote_results}

    async def sync_to_remotes(self) -> None:
        """Manual re-sync trigger. No-op by default (sync is synchronous on insert)."""
        logger.info("sync_to_remotes: no pending queue (inserts sync synchronously).")

    # ── Internal ──────────────────────────────────────────────────────────────

    @staticmethod
    def _build_embedder(config: Config):
        if config.EMBEDDING_PROVIDER == "gemini":
            from .embedders.gemini_embedder import GeminiEmbedder
            return GeminiEmbedder(config)
        from .embedders.openai_embedder import OpenAIEmbedder
        return OpenAIEmbedder(config)

    @staticmethod
    def _build_supabase(config: Config):
        if not config.ENABLE_SUPABASE:
            return None
        from .adapters.supabase_adapter import SupabaseAdapter
        return SupabaseAdapter(config)

    @staticmethod
    def _build_pinecone(config: Config):
        if not config.ENABLE_PINECONE:
            return None
        from .adapters.pinecone_adapter import PineconeAdapter
        return PineconeAdapter(config)

    @staticmethod
    def _build_llm_func(config: Config):
        """Build LLM completion function for entity extraction based on configured provider."""
        import os
        provider = config.LIGHTRAG_LLM_PROVIDER.lower()
        model = config.LIGHTRAG_LLM_MODEL

        if provider == "ollama":
            from lightrag.llm.ollama import ollama_model_complete

            async def _ollama(prompt, system_prompt=None, history_messages=None, **kwargs):
                if history_messages is None:
                    history_messages = []
                return await ollama_model_complete(
                    prompt, system_prompt=system_prompt,
                    history_messages=history_messages, **kwargs
                )
            return _ollama

        elif provider == "gemini":
            from lightrag.llm.gemini import gemini_complete_if_cache

            async def _gemini(prompt, system_prompt=None, history_messages=None, **kwargs):
                if history_messages is None:
                    history_messages = []
                return await gemini_complete_if_cache(
                    model, prompt,
                    system_prompt=system_prompt,
                    history_messages=history_messages,
                    api_key=config.GEMINI_API_KEY,
                    **kwargs,
                )
            return _gemini

        else:  # openai and compatible
            from lightrag.llm.openai import openai_complete_if_cache

            async def _openai(prompt, system_prompt=None, history_messages=None, keyword_extraction=False, **kwargs):
                if history_messages is None:
                    history_messages = []
                return await openai_complete_if_cache(
                    model, prompt,
                    system_prompt=system_prompt,
                    history_messages=history_messages,
                    api_key=config.OPENAI_API_KEY,
                    **kwargs,
                )
            return _openai

    def _has_remote_backends(self) -> bool:
        return self._supabase is not None or self._pinecone is not None

    def _preprocess(
        self, content: Union[str, Path, bytes], content_type: str
    ) -> tuple[bytes, str]:
        if content_type == "image":
            from .ingestors.image_ingestor import ImageIngestor
            src = content if isinstance(content, bytes) else Path(content)
            return ImageIngestor().process(src)
        if content_type == "audio":
            from .ingestors.audio_ingestor import AudioIngestor
            return AudioIngestor().process(content)
        if content_type == "video":
            from .ingestors.video_ingestor import VideoIngestor
            frames = VideoIngestor().extract_keyframes(content)
            if not frames:
                raise ValueError(
                    "No frames extracted from video. "
                    "Install opencv: pip install opencv-python-headless"
                )
            return frames[0], "image/jpeg"
        raise ValueError(f"Unknown content_type: {content_type!r}")

    async def _embed_multimodal(self, data: bytes, mime: str) -> list[float]:
        from .embedders.gemini_embedder import GeminiEmbedder
        if not isinstance(self._embedder, GeminiEmbedder):
            raise ValueError(
                "EMBEDDING_PROVIDER must be 'gemini' for multimodal content"
            )
        return await self._embedder.embed_bytes(data, mime)

    async def _sync_to_remotes(
        self, id_: str, embedding: list[float], meta: dict
    ) -> None:
        for adapter, name in [
            (self._supabase, "Supabase"),
            (self._pinecone, "Pinecone"),
        ]:
            if adapter is None:
                continue
            try:
                await adapter.upsert(id_, embedding, meta)
            except Exception as e:
                logger.warning("%s sync failed (continuing): %s", name, e)

    async def _search_remotes(
        self, embedding: list[float], top_k: int
    ) -> list[dict]:
        tasks, labels = [], []
        if self._supabase:
            tasks.append(self._supabase.search(embedding, top_k))
            labels.append("supabase")
        if self._pinecone:
            tasks.append(self._pinecone.search(embedding, top_k))
            labels.append("pinecone")

        merged = []
        for label, result in zip(labels, await asyncio.gather(*tasks, return_exceptions=True)):
            if isinstance(result, Exception):
                logger.warning("%s search failed: %s", label, result)
            else:
                merged.extend(result)
        return merged


async def _embed_and_mirror(
    texts: list[str], embedder, supabase, pinecone_
):
    """Embedding func injected into LightRAG — mirrors to remote backends after embed."""
    import numpy as np
    embeddings = await embedder.embed_text(texts)

    if supabase is not None or pinecone_ is not None:
        for text, emb in zip(texts, embeddings):
            id_ = hashlib.md5(text.encode()).hexdigest()
            meta = {"content_type": "text", "text": text[:500]}
            for adapter, name in [(supabase, "Supabase"), (pinecone_, "Pinecone")]:
                if adapter is None:
                    continue
                try:
                    await adapter.upsert(id_, list(emb) if hasattr(emb, "tolist") else emb, meta)
                except Exception as e:
                    logger.warning("%s mirror failed (continuing): %s", name, e)

    return np.array(embeddings)
