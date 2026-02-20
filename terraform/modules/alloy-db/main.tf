resource "google_alloydb_cluster" "mia_dod_cluster" {
  cluster_id = var.cluster_id
  location   = var.region
  network    = var.network_id

  initial_user {
    password = var.db_password
  }
}

resource "google_alloydb_instance" "primary_instance" {
  cluster       = google_alloydb_cluster.mia_dod_cluster.name
  instance_id   = "primary-instance"
  instance_type = "PRIMARY"

  machine_config {
    cpu_count = 4 # Increased for ScaNN/AI performance
  }

  database_flags = {
    "google_columnar_engine.enabled" = "on"
  }
}