variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "domains" {
  type = set(string)
}
