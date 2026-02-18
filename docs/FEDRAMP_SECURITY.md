# MIA-DoD Security & FedRAMP Compliance

## 🛡️ Data Sovereignty
* **Region-Locking:** All GCP resources are constrained to `us-east1` and `us-west1` via Organizational Policy to comply with US-only data residency requirements.
* **CMEK:** All data at rest in AlloyDB and Pub/Sub is encrypted using **Customer-Managed Encryption Keys** via Cloud KMS.

## 🔒 Network Isolation
* **VPC Service Controls (VPC-SC):** A service perimeter is established around the project to prevent data exfiltration to unauthorized external APIs or buckets.
* **Private Google Access:** Dataflow workers communicate with AlloyDB via private IP only—no public internet exposure.

## 🆔 Identity & Access
* **Zero-Key Policy:** No static service account keys (.json files) are permitted.
* **Workload Identity:** Dataflow workers and AI Agents use **Workload Identity Federation** to assume temporary, least-privilege roles.

## 📝 Audit & Observability
* **Cloud Audit Logs:** All data access and administrative actions are logged and exported to a secured Log Bucket for forensic review.
