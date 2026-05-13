#!/usr/bin/env python3
"""
LightRAG Plus — Backend Provisioning

Creates Supabase schema and Pinecone index whenever credentials are present.
Independent of ENABLE_SUPABASE / ENABLE_PINECONE flags — provision once up front
so flipping the flags later "just works" with no extra setup step.

Idempotent — safe to run on every startup (skips if already provisioned).

Usage:
    cd tools/lightrag
    uv run python provision.py
"""
import asyncio
import os
import re
import ssl
import sys
from pathlib import Path

import httpx

# Ensure UTF-8 output on Windows consoles
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# Bypass SSL verification for corporate proxy environments (no-op in standard envs).
# ssl._create_default_https_context covers stdlib http.client.
# httpx.HTTPTransport patch covers Pinecone v9 (passes verify to Client but not Transport).
ssl._create_default_https_context = ssl._create_unverified_context  # noqa: SLF001
_orig_transport_init = httpx.HTTPTransport.__init__
def _no_verify_transport(self, *args, **kwargs):
    kwargs.setdefault("verify", False)
    _orig_transport_init(self, *args, **kwargs)
httpx.HTTPTransport.__init__ = _no_verify_transport

sys.path.insert(0, str(Path(__file__).parent))

from src.config import Config, ConfigError


def _extract_project_ref(supabase_url: str) -> str:
    match = re.match(r"https://([^.]+)\.supabase\.co", supabase_url)
    if not match:
        raise ValueError(f"Cannot extract project ref from SUPABASE_URL: {supabase_url!r}")
    return match.group(1)


def _build_schema_sql(dim: int) -> str:
    """Read schema/supabase_schema.sql and substitute actual embedding dimension."""
    schema_path = Path(__file__).parent / "schema" / "supabase_schema.sql"
    sql = schema_path.read_text(encoding="utf-8")
    # Replace every occurrence of the default 1536 dimension
    sql = sql.replace("vector(1536)", f"vector({dim})")
    return sql


async def provision_supabase(config: Config) -> bool:
    print("  Provisioning Supabase schema...", end=" ", flush=True)

    if not config.SUPABASE_MANAGEMENT_TOKEN:
        print("SKIP")
        print("    SUPABASE_MANAGEMENT_TOKEN not set.")
        print("    Get token: supabase.com → Account → Access Tokens")
        print("    Add to .env: SUPABASE_MANAGEMENT_TOKEN=sbp_...")
        return False

    try:
        ref = _extract_project_ref(config.SUPABASE_URL)
        sql = _build_schema_sql(config.EMBEDDING_DIM)

        async with httpx.AsyncClient(timeout=30, verify=False) as client:
            resp = await client.post(
                f"https://api.supabase.com/v1/projects/{ref}/database/query",
                headers={
                    "Authorization": f"Bearer {config.SUPABASE_MANAGEMENT_TOKEN}",
                    "Content-Type": "application/json",
                },
                json={"query": sql},
            )

        if resp.status_code in (200, 201):
            print(f"OK (project={ref}, dim={config.EMBEDDING_DIM})")
            return True
        else:
            print(f"FAIL ({resp.status_code})")
            print(f"    Response: {resp.text[:400]}")
            return False

    except Exception as e:
        print(f"ERROR")
        print(f"    {e}")
        return False


async def provision_pinecone(config: Config) -> bool:
    print("  Provisioning Pinecone index...", end=" ", flush=True)

    try:
        from pinecone import Pinecone, ServerlessSpec

        pc = Pinecone(api_key=config.PINECONE_API_KEY, ssl_verify=False)
        existing_names = [i.name for i in pc.list_indexes()]

        if config.PINECONE_INDEX in existing_names:
            print(f"OK (index '{config.PINECONE_INDEX}' already exists)")
            return True

        # Parse region/cloud from PINECONE_ENVIRONMENT (e.g. "us-east-1-aws" → cloud=aws, region=us-east-1)
        env = config.PINECONE_ENVIRONMENT
        if env.endswith("-aws"):
            cloud, region = "aws", env[:-4]
        elif env.endswith("-gcp"):
            cloud, region = "gcp", env[:-4]
        elif env.endswith("-azure"):
            cloud, region = "azure", env[:-6]
        else:
            cloud, region = "aws", "us-east-1"

        pc.create_index(
            name=config.PINECONE_INDEX,
            dimension=config.EMBEDDING_DIM,
            metric="cosine",
            spec=ServerlessSpec(cloud=cloud, region=region),
        )
        print(f"OK (created '{config.PINECONE_INDEX}', dim={config.EMBEDDING_DIM})")
        return True

    except Exception as e:
        print(f"ERROR")
        print(f"    {e}")
        return False


async def main() -> None:
    print("\nLightRAG Plus — Backend Provisioning")
    print("=" * 40)

    try:
        config = Config()
    except (ConfigError, EnvironmentError) as e:
        print(f"Config error: {e}")
        sys.exit(1)

    has_supabase = bool(config.SUPABASE_URL and config.SUPABASE_MANAGEMENT_TOKEN)
    has_pinecone = bool(config.PINECONE_API_KEY)

    if not has_supabase and not has_pinecone:
        print("No backend credentials found — skipping provisioning.")
        print("  Supabase : set SUPABASE_URL + SUPABASE_MANAGEMENT_TOKEN in .env")
        print("  Pinecone : set PINECONE_API_KEY in .env")
        sys.exit(0)

    print(f"  Embedding dim : {config.EMBEDDING_DIM}")
    print(f"  Supabase      : {'credentials present' if has_supabase else 'skipped (no credentials)'}")
    print(f"  Pinecone      : {'credentials present' if has_pinecone else 'skipped (no credentials)'}")
    print()

    results = []

    if has_supabase:
        results.append(await provision_supabase(config))

    if has_pinecone:
        results.append(await provision_pinecone(config))

    print()
    if all(results):
        print("✓ All backends provisioned.")
        print("  Verify connections: uv run python setup_backends.py")
    else:
        print("✗ Some backends failed — see messages above.")
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())
