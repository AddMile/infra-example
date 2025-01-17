variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "database_version" {
  type = string
}

variable "tier" {
  type = string
}

variable "vpc_network_id" {
  type = string
}

variable "backup_enabled" {
  type = bool
}

variable "deletion_protection" {
  type = bool
}

variable "query_insights_enabled" {
  type = bool
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
}
