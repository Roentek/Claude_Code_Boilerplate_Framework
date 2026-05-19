import asyncio
import logging
from google import genai
from google.genai import types
from tenacity import retry, stop_after_attempt, wait_exponential, before_sleep_log
from ..config import Config

logger = logging.getLogger(__name__)

_RETRY = dict(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=1, max=8),
    before_sleep=before_sleep_log(logger, logging.WARNING),
    reraise=True,
)


class GeminiEmbedder:
    def __init__(self, config: Config):
        self._client = genai.Client(api_key=config.GEMINI_API_KEY)
        self._model = config.GEMINI_EMBEDDING_MODEL
        self.dim = config.EMBEDDING_DIM

    async def embed_text(self, texts: list[str]) -> list[list[float]]:
        if not texts:
            return []
        results = []
        for text in texts:
            response = await self._call_embed(text)
            results.append(response.embeddings[0].values)
        return results

    async def embed_single(self, text: str) -> list[float]:
        results = await self.embed_text([text])
        return results[0]

    async def embed_bytes(self, data: bytes, mime_type: str) -> list[float]:
        """Embed raw bytes (image/audio) using Gemini multimodal embedding."""
        part = types.Part.from_bytes(data=data, mime_type=mime_type)
        response = await self._call_embed(part)
        return response.embeddings[0].values

    @retry(**_RETRY)
    async def _call_embed(self, contents):
        return await asyncio.to_thread(
            self._client.models.embed_content,
            model=self._model,
            contents=contents,
        )
