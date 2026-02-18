# ==========================================================
# MIA-DoD Agentic-GCP Nervous System
# main.tf: Core Infrastructure Provisioning (VPC & AlloyDB)
# ==========================================================

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Networking: Secure VPC for FedRAMP Isolation
resource "google_compute_network" "mia_dod_vpc" {
  name                    = "mia-dod-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "mia_dod_subnet" {
  name          = "mia-dod-subnet-us-east1"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.mia_dod_vpc.id
  
  # Required for Private Google Access (Dataflow to AlloyDB)
  private_ip_google_access = true
}

# 2. Messaging: The Ingestion Backbone
resource "google_pubsub_topic" "intel_ingestion" {
  name = "intel-ingestion-topic"
  
  # In production, add labels for cost-tracking per mission
  labels = {
    environment = "poc"
    agency      = "mia-dod"
  }
}

# 3. Storage: The AlloyDB High-Performance Cluster
resource "google_alloydb_cluster" "mia_dod_cluster" {
  cluster_id = "mia-dod-vector-cluster"
  location   = var.region
  network    = google_compute_network.mia_dod_vpc.id

  initial_user {
    password = var.db_password
  }
}

resource "google_alloydb_instance" "primary_instance" {
  cluster       = google_alloydb_cluster.mia_dod_cluster.name
  instance_id   = "primary-instance"
  instance_type = "PRIMARY"

  machine_config {
    cpu_count = 2 # Starts at 2 vCPU for AlloyDB
  }
}

# 4. Analytics: Read Pool for Agentic Dashboarding
resource "google_alloydb_instance" "read_pool" {
  cluster       = google_alloydb_cluster.mia_dod_cluster.name
  instance_id   = "read-pool-01"
  instance_type = "READ_POOL"
  
  read_pool_config {
    node_count = 1
  }

  machine_config {
    cpu_count = 2
  }
}
