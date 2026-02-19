# 🛠️ MIA-DoD DBA Maintenance Guide

This guide outlines the standard operating procedures for maintaining the MIA-DoD Nervous System data layer. These tasks ensure the system meets FedRAMP-High availability and performance standards.

## 1. Environment Lifecycle Management

### Initializing the Schema
Before data ingestion begins, the DBA must ensure the extensions and baseline tables are provisioned.

### Safe Teardown (Development Only)
To reset the environment for a new PoC phase:

## 2. Performance Tuning & Index Management

### Handling Index Bloat

In high-velocity streaming environments, indexes can become "bloated," leading to slow lookups.

1. Detection: Use the pgstattuple extension to check for fragmentation.

2. Remediation: Rebuild the index without locking out the Dataflow pipeline.

### Fine-Tuning Vacuuming for Intel Logs
Standard vacuuming settings are often too passive for defense-grade workloads.

Strategy: Adjust the autovacuum_vacuum_scale_factor for the intel_logs table to trigger more frequent cleanups of dead tuples.

## 3. Resilience & Disaster Recovery
### Manual Snapshots

While AlloyDB has automated backups, a DBA must trigger a manual snapshot before any major pipeline/ code deployment.

### Point-in-Time Recovery (PITR)
If a Dataflow bug causes data corruption, use PITR to restore to a state exactly 1 minute before the incident:

## 4. Monitoring & Observability
### Key Metrics to Watch:

* alloydb.googleapis.com/db/cpu/utilization: Threshold alert at 80%.

* alloydb.googleapis.com/db/postgres/transaction_id_age: Critical for preventing XID wraparound.

* alloydb.googleapis.com/db/storage/utilization: Watch for spikes in WAL (Write-Ahead Log) size.


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

# Tools

For deep-dive query optimization and visual plan analysis, I rely on pgAdmin 4. However, for real-time monitoring of a streaming environment like the MIA-DoD project, I use AlloyDB System Insights to track the Columnar Engine's health, and psql for fast, scripted maintenance tasks. I believe in using the right tool for the specific layer of the stack I'm troubleshooting.


## Index Advisor within Query Insights.
It actually suggests specific CREATE INDEX statements based on the queries it observes causing high load.


# Key PostgreSQL \pg_ Commands (CLI)
When you are in the terminal (psql), these are your "Swiss Army Knife" commands:

\di+: List all indexes, their sizes, and descriptions.

\dt+: List all tables with persistence and size info.

\watch [SEC]: Append this to any query (e.g., SELECT ... \watch 2) to create a live-updating dashboard in your terminal.

\conninfo: Verify which user and SSL/TLS certificate you are currently using (critical for FedRAMP audits).


# Reference

## 1. Connection & Querying
The most fundamental tool is psql. On GCP, you often wrap this with the Cloud SQL Proxy for security.

psql: The primary CLI for executing SQL.

Standard Connect: psql -h [IP_ADDRESS] -U [USERNAME] -d [DB_NAME]

GCP Proxy Connect: psql -h 127.0.0.1 -p 5432 -U postgres

pg_isready: Checks the connection status of a PostgreSQL server. Useful for health check scripts.

pg_isready -h [INSTANCE_IP] -p 5432

## 2. Backup & Migration (The "Big Three")
Essential tools, when moving data into or out of GCP.

[!IMPORTANT]
When exporting from Cloud SQL to import elsewhere, always use the --no-owner and --no-acl flags to avoid permission errors related to the GCP managed cloudsqladmin user.

pg_dump: Exports a single database into a script or archive file.

pg_dump -h [IP] -U postgres --format=plain --no-owner --no-acl [DB_NAME] > backup.sql

pg_dumpall: Exports the entire cluster (all databases, roles, and groups).

Note: In Cloud SQL, you must exclude the system database: --exclude-database=cloudsqladmin.

pg_restore: Used to restore backups created with the custom (-Fc) or directory formats of pg_dump.

pg_restore -h [IP] -U postgres -d [DB_NAME] -v "my_backup.dump"

## 3. Performance & Monitoring
While the GCP Console has Query Insights, these CLI tools are better for "live" debugging.

pg_bench: Runs a benchmark test on your instance. This is great for testing if a new machine type (e.g., moving from 4 vCPU to 8 vCPU) actually improves your specific workload.

pg_bench -i -s 10 [DB_NAME] (Initializes a test schema)

pg_bench -c 10 -t 1000 [DB_NAME] (Runs 10 clients, 1000 transactions each)

pg_activity: A "top-like" application for PostgreSQL server queries (requires installation via pip or your package manager). It shows running queries, PIDs, and waiting states in real-time.

## 4. Maintenance (Internal SQL Commands)

```Text

Command,Purpose
pg_terminate_backend(pid),Forcefully kills a stuck or long-running query.
pg_cancel_backend(pid),Gently stops a query without killing the connection.
pg_reload_conf(),Applies changes made to configuration files (limited in GCP).
pg_size_pretty(...),Converts bytes into readable formats (MB/GB) for table/DB sizes.

```

