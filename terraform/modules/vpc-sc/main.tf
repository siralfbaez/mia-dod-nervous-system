resource "google_access_context_manager_service_perimeter" "perimeter" {
  parent = "accessPolicies/${var.policy_id}"
  name   = "accessPolicies/${var.policy_id}/servicePerimeters/${var.perimeter_name}"
  title  = var.perimeter_name

  status {
    restricted_services = [
      "alloydb.googleapis.com",
      "dataflow.googleapis.com",
      "pubsub.googleapis.com"
    ]
    resources = ["projects/${var.project_number}"]
  }
}