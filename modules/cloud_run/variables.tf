variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "image" {
  type = string
}

variable "service_account" {
  type = string
}

variable "ingress" {
  type = string
}

variable "vpc_access_connector_id" {
  type = string
}

variable "db_volume_name" {
  type = string
}

variable "db_instance_connection_name" {
  type = string
}

variable "min_instance_count" {
  type = number
}

variable "max_instance_count" {
  type = number
}

