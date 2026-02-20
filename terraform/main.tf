# Call the VPC-SC Module
module "vpc_sc" {
  source         = "./modules/vpc-sc"
  project_number = var.project_number
  perimeter_name = "mia_dod_perimeter"
  policy_id      = var.access_policy_id
}

# Call the AlloyDB Module
module "alloy_db" {
  source      = "./modules/alloy-db"
  cluster_id  = "mia-dod-vector-cluster"
  region      = var.region
  network_id  = google_compute_network.mia_dod_vpc.id
  db_password = var.db_password
}