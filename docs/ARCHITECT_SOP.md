# The Architect's Activities

Focus: Overal System Design, Schema Design, Data Warehousing, and System Evolution.

# Vector Design & High Availability
Constraint: Ensure Read Pools are utilized for all LLM "Recall" queries to preserve Primary write-headroom.

# Index Fine-Tuning
### Activity: Analyzing Index Performance

1) Identify Bloat: Run pgstattuple on intel_logs_scann_idx.

2) Reindex: Use REINDEX INDEX CONCURRENTLY to avoid locking the table during production hours.

3) Tuning: Adjust fillfactor to 80 for tables with high update frequency to reduce page splits.

# Resilience: Backup & Recovery
Activity: Manual Snapshot & Point-in-Time Recovery (PITR)

Action: Trigger a manual AlloyDB backup before a major schema migration.

# Performance Tuning (Vacuuming)
Monitoring: Check n_dead_tup vs n_live_tup in pg_stat_all_tables.

Action: Manually trigger VACUUM ANALYZE on specific partitions after a massive Dataflow batch upload.
