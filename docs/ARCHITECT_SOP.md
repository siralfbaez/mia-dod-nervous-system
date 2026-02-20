# 🏛️ MIA-DoD Architect Activity Guide
Focus: Overal System Design, Schema Design, Data Warehousing, and System Evolution.

## 🛰️ Mission-Critical Data Strategy
End-to-End Pipeline Design: I have architected a low-latency, "always-on" streaming ingestion framework using Google Cloud Pub/Sub as the messaging backbone and Dataflow (Apache Beam) for stateful processing. This system transforms raw telemetry into actionable intelligence through complex windowing, side-inputs, and schema-on-write validation, ultimately landing the data in AlloyDB (PostgreSQL) for high-performance vector search and analytical recall.


## 🧠 Advanced Dataflow (Apache Beam) Patterns
To meet the requirements for the Google technical lead, we implement the following advanced streaming patterns:

1. Stateful Processing & Windowing
* Windowing Strategy: We utilize Fixed Windows for standard telemetry and Session <br>
     Windows to group related intelligence events that occur in bursts.
<br>
* Handling Lateness: We implement Allowed Lateness with custom Triggers to ensure that data arriving after the watermark is still incorporated into the state without restarting the pipeline.

2. Stream Enrichment via Side Inputs
* The Pattern: We use Side Inputs to inject slowly-changing metadata (e.g., sensor location or security clearance levels) into the main telemetry stream.

* Optimization: To prevent worker memory issues, we use ```AsSingleton``` or ```AsIterables``` for lookups, ensuring the pipeline remains performant even with millions of events.

3. Schema-on-Write Validation
* Data Integrity: Before reaching AlloyDB, every PCollection is validated against a central schema.

* Error Handling: Invalid records are diverted to a Dead Letter Queue (DLQ) in Cloud Storage/BigQuery for manual audit, ensuring the primary database remains clean and FedRAMP-compliant.

# ⚡ Pub/Sub Messaging Backbone
* Message Ordering: Critical for defense telemetry. We enable Ordering Keys at the topic level to ensure sequential processing in Dataflow.

* Resiliency: We utilize Pub/Sub Snapshots to allow for 7-day data replay capabilities in the event of a downstream database migration or failure.

# AlloyDB (PostgreSQL)

...[PlaceHolder]
Activity: Manual Snapshot & Point-in-Time Recovery (PITR)

Action: Trigger a manual AlloyDB backup before a major schema migration.
