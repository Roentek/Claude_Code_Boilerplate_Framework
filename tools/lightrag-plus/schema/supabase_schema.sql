-- LightRAG Plus — Supabase Schema
-- Run this in your Supabase SQL Editor before enabling ENABLE_SUPABASE=true
--
-- IMPORTANT: Adjust the vector dimension to match your EMBEDDING_DIM:
--   text-embedding-3-small  → 1536  (default OpenAI)
--   text-embedding-3-large  → 3072
--   gemini-embedding-2-preview → 3072
--   gemini-embedding-2      → 768
--
-- Change all occurrences of 1536 below to match your chosen dimension.

-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- ── Main table ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS lightrag_vectors (
    id           TEXT PRIMARY KEY,
    embedding    vector(1536) NOT NULL,   -- ← adjust dimension here
    content_type TEXT NOT NULL DEFAULT 'text',
    mime_type    TEXT,
    text         TEXT DEFAULT '',
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- IVFFlat index for fast approximate cosine search
-- Rebuild with ANALYZE after bulk inserts (lists ≈ sqrt(rows))
CREATE INDEX IF NOT EXISTS lightrag_vectors_embedding_idx
    ON lightrag_vectors
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);

-- ── Similarity search RPC ─────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION match_lightrag_vectors(
    query_embedding vector,   -- ← must match table dimension
    match_count     INT DEFAULT 10
)
RETURNS TABLE (
    id           TEXT,
    content_type TEXT,
    text         TEXT,
    similarity   FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        lv.id,
        lv.content_type,
        lv.text,
        1 - (lv.embedding <=> query_embedding) AS similarity
    FROM lightrag_vectors lv
    ORDER BY lv.embedding <=> query_embedding
    LIMIT match_count;
END;
$$;
