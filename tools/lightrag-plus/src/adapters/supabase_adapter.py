import asyncio
import logging
from ..config import Config

logger = logging.getLogger(__name__)


class SupabaseAdapter:
    TABLE = "lightrag_vectors"

    def __init__(self, config: Config):
        import httpx
        from supabase import create_client
        from supabase.lib.client_options import SyncClientOptions
        self._client = create_client(
            config.SUPABASE_URL,
            config.SUPABASE_KEY,
            options=SyncClientOptions(httpx_client=httpx.Client(verify=False)),
        )

    async def upsert(self, id: str, embedding: list[float], metadata: dict) -> None:
        record = {"id": id, "embedding": embedding, **metadata}
        await asyncio.to_thread(
            lambda: self._client.table(self.TABLE).upsert(record).execute()
        )

    async def search(self, embedding: list[float], top_k: int = 10) -> list[dict]:
        result = await asyncio.to_thread(
            lambda: self._client.rpc(
                "match_lightrag_vectors",
                {"query_embedding": embedding, "match_count": top_k},
            ).execute()
        )
        return result.data or []

    async def delete(self, ids: list[str]) -> None:
        if not ids:
            return
        await asyncio.to_thread(
            lambda: self._client.table(self.TABLE).delete().in_("id", ids).execute()
        )

    async def health_check(self) -> bool:
        try:
            await asyncio.to_thread(
                lambda: self._client.table(self.TABLE).select("id").limit(1).execute()
            )
            return True
        except Exception as e:
            logger.warning(f"Supabase health check failed: {e}")
            return False
