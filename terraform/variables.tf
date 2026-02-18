variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  default = "us-east1"
}

variable "db_password" {
  description = "The root password for AlloyDB"
  type        = string
  sensitive   = true
}
