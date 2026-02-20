CREATE EXTENSION IF NOT EXISTS "alloydb_ai";

CREATE TABLE IF NOT EXISTS neural_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content TEXT NOT NULL,
    embedding vector(768),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX neural_records_scann_idx ON neural_records 
USING scann (embedding cosine) 
WITH (num_leaves = 1000);
