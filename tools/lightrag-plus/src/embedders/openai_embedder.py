from openai import AsyncOpenAI
from ..config import Config


class OpenAIEmbedder:
    def __init__(self, config: Config):
        self._client = AsyncOpenAI(api_key=config.OPENAI_API_KEY)
        self._model = config.OPENAI_EMBEDDING_MODEL
        self.dim = config.EMBEDDING_DIM

    async def embed_text(self, texts: list[str]) -> list[list[float]]:
        if not texts:
            return []
        response = await self._client.embeddings.create(model=self._model, input=texts)
        return [item.embedding for item in response.data]

    async def embed_single(self, text: str) -> list[float]:
        results = await self.embed_text([text])
        return results[0]
