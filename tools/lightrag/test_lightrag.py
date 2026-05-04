#!/usr/bin/env python3
"""
Quick test script for LightRAG - simplified version
Just tests that LightRAG can initialize and basic operations work
"""

from lightrag import LightRAG, QueryParam
from lightrag.llm.openai import gpt_4o_mini_complete, openai_embed
import asyncio

async def main():
    print("="*80)
    print("LightRAG Test - OpenAI GPT-4o-mini")
    print("="*80)

    # Initialize LightRAG
    print("\n[1/4] Initializing LightRAG...")
    rag = LightRAG(
        working_dir="./rag_storage",
        llm_model_func=gpt_4o_mini_complete,
        embedding_func=openai_embed
    )

    # Initialize storage
    print("[2/4] Initializing storage...")
    await rag.initialize_storages()

    # Insert test document
    print("[3/4] Inserting test document...")
    test_text = """
    LightRAG is a graph-based Retrieval-Augmented Generation system.
    It extracts entities and relationships from documents to build knowledge graphs.
    This enables more accurate retrieval by understanding semantic connections.
    """

    await rag.ainsert(test_text)
    print("      Document inserted successfully!")

    # Query
    print("[4/4] Querying: 'What is LightRAG?'")
    result = await rag.aquery(
        "What is LightRAG?",
        param=QueryParam(mode="naive")
    )

    print("\n" + "="*80)
    print("QUERY RESULT:")
    print("="*80)
    print(result)
    print("="*80)

    print("\n[SUCCESS] Test completed!")
    print(f"Data saved to: ./rag_storage/")
    print("\nTo explore the knowledge graph, start the server:")
    print("  uv run python -m lightrag.api.lightrag_server --port 9621")

if __name__ == "__main__":
    asyncio.run(main())
