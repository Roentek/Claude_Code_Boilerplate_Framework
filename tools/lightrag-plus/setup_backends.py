#!/usr/bin/env python3
"""
Validate LightRAG Plus backend connections.

Usage:
    cd tools/lightrag-plus
    uv run python setup_backends.py
"""
import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from src.config import Config, ConfigError


async def check_supabase(config: Config) -> bool:
    print("  Checking Supabase...", end=" ", flush=True)
    try:
        from src.adapters.supabase_adapter import SupabaseAdapter
        ok = await SupabaseAdapter(config).health_check()
    except Exception as e:
        print(f"ERROR ({e})")
        return False
    if ok:
        print("OK")
    else:
        print("FAIL")
        print("    → Run schema/supabase_schema.sql in your Supabase SQL Editor")
    return ok


async def check_pinecone(config: Config) -> bool:
    print("  Checking Pinecone...", end=" ", flush=True)
    try:
        from src.adapters.pinecone_adapter import PineconeAdapter
        ok = await PineconeAdapter(config).health_check()
    except Exception as e:
        print(f"ERROR ({e})")
        return False
    if ok:
        print("OK")
    else:
        print("FAIL")
        print(f"    → Verify index '{config.PINECONE_INDEX}' exists in Pinecone")
    return ok


async def main() -> None:
    print("\nLightRAG Plus — Backend Validation")
    print("=" * 40)

    try:
        config = Config()
    except (ConfigError, EnvironmentError) as e:
        print(f"Config error: {e}")
        sys.exit(1)

    print(f"  Embedding provider : {config.EMBEDDING_PROVIDER}")
    model = (
        config.OPENAI_EMBEDDING_MODEL
        if config.EMBEDDING_PROVIDER == "openai"
        else config.GEMINI_EMBEDDING_MODEL
    )
    print(f"  Embedding model    : {model}")
    print(f"  Embedding dim      : {config.EMBEDDING_DIM}")
    print(f"  Multimodal mode    : {config.MULTIMODAL_MODE}")
    print(f"  Supabase enabled   : {config.ENABLE_SUPABASE}")
    print(f"  Pinecone enabled   : {config.ENABLE_PINECONE}")
    print()

    results = []
    if config.ENABLE_SUPABASE:
        results.append(await check_supabase(config))
    else:
        print("  Supabase: disabled")

    if config.ENABLE_PINECONE:
        results.append(await check_pinecone(config))
    else:
        print("  Pinecone: disabled")

    if not config.ENABLE_SUPABASE and not config.ENABLE_PINECONE:
        print("  No remote backends enabled — LightRAG core only (local nano-vectordb)")

    print()
    if all(results) if results else True:
        print("All backends OK")
    else:
        print("Some backends failed — see messages above")
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())
