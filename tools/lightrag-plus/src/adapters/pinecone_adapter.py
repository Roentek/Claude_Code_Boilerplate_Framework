import asyncio
import logging
from ..config import Config

logger = logging.getLogger(__name__)


class PineconeAdapter:
    def __init__(self, config: Config):
        import httpx
        # Pinecone v9 passes ssl_verify to httpx.Client but NOT to httpx.HTTPTransport;
        # httpx ignores verify= when a custom transport is provided — patch the transport.
        _orig = httpx.HTTPTransport.__init__
        def _no_verify(self, *a, **kw):
            kw.setdefault("verify", False)
            _orig(self, *a, **kw)
        httpx.HTTPTransport.__init__ = _no_verify

        from pinecone import Pinecone
        pc = Pinecone(api_key=config.PINECONE_API_KEY, ssl_verify=False)
        self._index = pc.Index(config.PINECONE_INDEX)

    async def upsert(self, id: str, embedding: list[float], metadata: dict) -> None:
        await asyncio.to_thread(
            self._index.upsert,
            vectors=[{"id": id, "values": embedding, "metadata": metadata}],
        )

    async def search(self, embedding: list[float], top_k: int = 10) -> list[dict]:
        result = await asyncio.to_thread(
            self._index.query,
            vector=embedding,
            top_k=top_k,
            include_metadata=True,
        )
        return [
            {"id": m.id, "score": m.score, **(m.metadata or {})}
            for m in result.matches
        ]

    async def delete(self, ids: list[str]) -> None:
        if not ids:
            return
        await asyncio.to_thread(self._index.delete, ids=ids)

    async def health_check(self) -> bool:
        try:
            await asyncio.to_thread(self._index.describe_index_stats)
            return True
        except Exception as e:
            logger.warning(f"Pinecone health check failed: {e}")
            return False
