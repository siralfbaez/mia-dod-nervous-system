variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "project_number" {
  description = "The numeric Project ID (required for VPC-SC)"
  type        = string
}

variable "region" {
  description = "GCP Region for deployment"
  type        = string
  default     = "us-east1"
}

variable "db_password" {
  description = "The root password for AlloyDB"
  type        = string
  sensitive   = true
}

# --- New Variables for FedRAMP & Modularization ---

variable "kms_key_id" {
  description = "The URI of the Cloud KMS key for CMEK encryption"
  type        = string
}

variable "access_policy_id" {
  description = "The ID of the Access Context Manager Policy for VPC-SC"
  type        = string
}

variable "cluster_id" {
  description = "The ID of the AlloyDB cluster"
  type        = string
  default     = "mia-dod-vector-cluster"
}
