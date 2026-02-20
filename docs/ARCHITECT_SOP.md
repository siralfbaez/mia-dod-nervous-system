# 🏛️ MIA-DoD Architect Activity Guide
Focus: Overal System Design, Schema Design, Data Warehousing, and System Evolution.

## 🛰️ Mission-Critical Data Strategy
End-to-End Pipeline Design: I have architected a low-latency, "always-on" streaming ingestion framework using Google Cloud Pub/Sub as the messaging backbone and Dataflow (Apache Beam) for stateful processing. This system transforms raw telemetry into actionable intelligence through complex windowing, side-inputs, and schema-on-write validation, ultimately landing the data in AlloyDB (PostgreSQL) for high-performance vector search and analytical recall.


## 🧠 Advanced Dataflow (Apache Beam) Patterns
Leverage Stateful (State & Timer API) processing for use cases like sessionization or complex event detection. I utilize Side Inputs for real-time enrichment and CoGroupByKey for joining disparate streams (e.g., matching sensor data with asset metadata) in a distributed environment.

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
     * Purpose: To catch "valid" messages that fail your business logic or schema validation (e.g., a field is missing, or an insert into AlloyDB fails due to a constraint violation). 
     * How: You use a ```TupleTag``` to create a "Side Output."


### Performance & Scaling:
Optimize Dataflow throughput by managing Shuffle service efficiency and addressing Data Skew (Hot Keys). I leverage Streaming Engine and Vertical Autoscaling to maintain sub-second processing latencies while optimizing cost-per-message.

# ⚡ Pub/Sub Messaging Backbone
   * Message Ordering: Critical for defense telemetry. We enable Ordering Keys at the topic level to ensure sequential processing in Dataflow.
   * Resiliency: We utilize Pub/Sub Snapshots to allow for 7-day data replay capabilities in the event of a downstream database migration or failure.
   * The Pub/Sub Level (Transport Failures): 
     * Purpose: To catch messages that simply cannot be acknowledged (e.g., the message format is so corrupted the Dataflow worker crashes before it can even process it, or the "Max Delivery Attempts" are exceeded). 
     * How: In the Google Cloud Console or CLI, you edit the subscription and point it to a "Dead Letter Topic."

###  Pub/Sub "Seek" for Disaster Recovery
"Seek" is our "Rewind" button. Our, Replay strategy.

Zero Data Loss, I'm keeping in mind these three pillars:

* Idempotency: "Since I am replaying data using Seek, I ensure my writes to AlloyDB or BigQuery are idempotent (using UPSERT or unique IDs) so I don't create duplicate records."
* Snapshots: "I automate snapshots before any major pipeline update."
* Checkpointing: "I rely on Dataflow’s internal checkpointing to ensure that even if a worker fails, the state is preserved."

| Tool | Action | Scenario |
| :--- | :--- | :--- |
| Pub/Sub DLQ | Automatic | Message is "un-processable" (format/system error). |
| Dataflow Side Output | Code-defined | Business logic failure (e.g., "Age" cannot be negative). |
| Pub/Sub Seek | Manual/Scripted | Pipeline bug found; need to re-run the last 4 hours of data. |


# AlloyDB (PostgreSQL)

### The Workflow: Dataflow to AlloyDB AI
The "Mission"; RAG (Retrieval-Augmented Generation) pipeline. The flow:

1) Ingestion: Dataflow pulls raw text/images from Pub/Sub or GCS.

2) Real-time Vectorization: Within a DoFn, Dataflow makes a call to a Vertex AI Embedding Model (like text-embedding-004).

3) Enrichment: Attach that high-dimensional vector (the "embedding") to the original data record.

4) The Sink: Dataflow writes the record + the vector into AlloyDB.

### AlloyDB Integration (The "ScaNN" Advantage)
To bridging the gap between Dataflow and AlloyDB AI. I build pipelines that perform real-time vectorization via Vertex AI endpoints, sinking enriched data into AlloyDB with ScaNN-optimized indexing for high-performance recall

# Compliance & Governance:
Keeping in mind our US data is a serious national security matter; I’m deploying data platforms within FedRAMP-High boundaries. This includes implementing VPC Service Controls, CMEK (Customer-Managed Encryption Keys) for data-at-rest in Pub/Sub, and ensuring all Dataflow worker communication remains within private network perimeters.

### Private Network Perimeters: "No Public IPs"
In a FedRAMP High mission, the Dataflow workers should never have a public IP address.<br>

FedRAMP High is System and Communications Protection (SC-7).<br>
In my designs, I ensure that all Dataflow workers communicate solely over the Google private backbone. By disabling public IPs and utilizing Private Service Connect (PSC) endpoints, I maintain a hardened boundary that satisfies FedRAMP High's strict 'Boundary Protection' controls.

* The Setup:
  * ```--usePublicIps=false```: This flag ensures workers only have internal VPC IPs. 
  * Private Google Access: You must enable this on your subnetwork so workers can still reach Google APIs (like BigQuery or Vertex AI) without needing the public internet. 
  * Firewall Rules: You restrict worker-to-worker communication to only the necessary ports for shuffling data (usually TCP 12345-12346).

  * <br>

#### Few more notes 
* FIPS 140-2: Encryption (via KMS) uses FIPS-validated modules.
* Assured Workloads: I deploy within an Assured Workloads folder to automate the enforcement of these FedRAMP High "guardrails."
* Shared Responsibility Model: I Acknowledge that while Google secures the infrastructure, I and anyone  are responsible for the secure configuration of the pipeline (CMEK, VPC SC).


...[PlaceHolder:proper and accurate steps/instructions are being added/updated as I progress]
Activity: Manual Snapshot & Point-in-Time Recovery (PITR)

Action: Trigger a manual AlloyDB backup before a major schema migration.
