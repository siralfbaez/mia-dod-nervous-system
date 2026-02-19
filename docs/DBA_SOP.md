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
