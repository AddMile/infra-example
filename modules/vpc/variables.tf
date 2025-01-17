variable "region" {
  type = string
}

variable "network_name" {
  type = string
}

variable "vpc_subnetwork_name" {
  type = string
}

variable "vpc_access_connector_name" {
  type = string
}

variable "vpc_access_connector_machine_type" {
  type = string
}

variable "vpc_access_connector_min_instances" {
  type = number
}

variable "vpc_access_connector_max_instances" {
  type = number
}
