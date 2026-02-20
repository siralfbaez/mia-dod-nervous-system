# --- AlloyDB Outputs ---
output "alloydb_instance_ip" {
  description = "Internal IP for the AlloyDB primary instance"
  value       = module.alloy-db.primary_instance_ip
}

output "alloydb_cluster_id" {
  description = "The ID of the AlloyDB cluster"
  value       = module.alloy-db.cluster_id
}

# --- Security & KMS Outputs ---
output "kms_key_id" {
  description = "CMEK Key ID for FedRAMP compliance"
  value       = var.kms_key_id
}

output "vpc_network_id" {
  description = "The VPC ID for worker placement"
  value       = module.vpc_sc.network_id
}
