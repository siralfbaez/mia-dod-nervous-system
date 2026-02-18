-- ==========================================================
-- MIA-DoD Agentic-GCP Nervous System
-- 01_init_vector.sql: AlloyDB ScaNN & pgvector Initialization
-- ==========================================================

-- 1. Enable high-performance AI and Vector extensions
CREATE EXTENSION IF NOT EXISTS google_ml_integration CASCADE;
CREATE EXTENSION IF NOT EXISTS vector CASCADE;

-- 2. Create the Intel Logs table with Vector Support
-- Designed for FedRAMP-regulated high-concurrency ingestion
CREATE TABLE IF NOT EXISTS intel_logs (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_origin TEXT NOT NULL,
    classification TEXT NOT NULL, -- e.g., 'TOP_SECRET', 'SECRET'
    content TEXT NOT NULL,
    embedding_vector vector(768), -- Matches Gemini/Vertex AI embedding dimensions
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Configure the ScaNN Index (The Google "Secret Weapon")
-- ScaNN provides up to 10x faster query performance than standard HNSW.
-- We apply this to the embedding_vector column for sub-second recall.
CREATE INDEX IF NOT EXISTS intel_logs_scann_idx 
ON intel_logs 
USING columnar (embedding_vector)
WITH (google_scann_enabled = true);

-- 4. Enable Columnar Engine for Analytical Queries
-- This speeds up non-vector filtering (e.g., filtering by classification)
-- alongside the vector search.
ALTER TABLE intel_logs SET (google_columnar_engine.enabled = true);

-- 5. Helper View for AI Agent Recall
-- Provides a clean interface for the Agentic 'Memory' layer
CREATE OR REPLACE VIEW v_agentic_memory_recall AS
SELECT 
    log_id, 
    content, 
    classification, 
    created_at
FROM intel_logs;
