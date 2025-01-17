variable "state_bucket" {
  type    = string
  default = "project-dev-example-terraform-state"
}

variable "project_id" {
  type    = string
  default = "project-dev"
}

variable "project_number" {
  type    = number
  default = 12312313213213
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "google_apis" {
  type = set(string)
  default = [
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "compute.googleapis.com",
    "vpcaccess.googleapis.com",
    "run.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudscheduler.googleapis.com",
  ]
}

# Service accounts

variable "deploy_service_account_name" {
  type    = string
  default = "deploy-example-sa"
}

variable "deploy_service_account_display_name" {
  type    = string
  default = "Deploy service account for example"
}

variable "deploy_service_account_roles" {
  type = set(string)
  default = [
    "roles/artifactregistry.admin",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountUser",
    "roles/run.developer",
  ]
}

variable "runtime_service_account_name" {
  type    = string
  default = "runtime-example-sa"
}

variable "runtime_service_account_display_name" {
  type    = string
  default = "Runtime service account for example"
}

variable "runtime_service_account_roles" {
  type = set(string)
  default = [
    "roles/pubsub.publisher",
    "roles/firebaseauth.admin",
  ]
}

# Artifact Registry

variable "artifact_registry_repository_name" {
  type    = string
  default = "example"
}

variable "api_image_name" {
  type    = string
  default = "api"
}

variable "worker_image_name" {
  type    = string
  default = "worker"
}

# Serverless Network

variable "vpc_network_name" {
  type    = string
  default = "example-vpc"
}

variable "vpc_access_connector_name" {
  type    = string
  default = "example-connector"
}

variable "vpc_access_connector_machine_type" {
  type    = string
  default = "f1-micro"
}

variable "vpc_access_connector_min_instances" {
  type    = number
  default = 2
}

variable "vpc_access_connector_max_instances" {
  type    = number
  default = 3
}

# Cloud Run 

variable "api_name" {
  type    = string
  default = "example-api"
}

variable "worker_name" {
  type    = string
  default = "example-worker"
}

variable "api_ingress" {
  type    = string
  default = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
}

variable "worker_ingress" {
  type    = string
  default = "INGRESS_TRAFFIC_INTERNAL_ONLY"
}

variable "api_min_instance_count" {
  type    = number
  default = 0
}

variable "api_max_instance_count" {
  type    = number
  default = 2
}

variable "worker_min_instance_count" {
  type    = number
  default = 0
}

variable "worker_max_instance_count" {
  type    = number
  default = 2
}

# Load Balancer

variable "load_balancer_name" {
  type    = string
  default = "project-example"
}

variable "example_api_domains" {
  type    = set(string)
  default = ["api.example.com"]
}

# Cloud SQL

variable "db_instance_name" {
  type    = string
  default = "project"
}

variable "db_version" {
  type    = string
  default = "POSTGRES_16"
}

variable "db_tier" {
  type    = string
  default = "db-f1-micro"
}

variable "db_volume_name" {
  type    = string
  default = "cloudsql"
}

variable "db_name" {
  type    = string
  default = "example"
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_backup_enabled" {
  type    = bool
  default = false
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

variable "db_query_insights_enabled" {
  type    = bool
  default = false
}

# Pub/Sub

variable "topic_subs" {
  description = "Map of topics with their respective subscriptions and push endpoints"
  type = map(object({
    subscriptions = list(object({
      name          = string
      push_endpoint = string
    }))
  }))
  default = {
    "example.user.created" = {
      subscriptions = [
        {
          name          = "sub.example.email.user.created"
          push_endpoint = "/v1/email-user-created"
        }
      ]
    },
  }
}

# Jobs

variable "jobs" {
  type = list(object({
    name        = string
    topic       = string
    description = string
    schedule    = string
    time_zone   = string
    retry_count = number
    data        = map(any)
  }))
  default = [
    {
      name        = "create-coaches-timeslots"
      topic       = "example.coaches.create-timeslots"
      description = "job that creates timeslots for coaches"
      schedule    = "0 1 * * *" # every day at 1 AM
      time_zone   = "UTC"
      retry_count = 3
      data        = {}
    },
  ]
}

# Monitoring

variable "monitoring_slack_channel" {
  type    = string
  default = "#example-alerts-dev"
}

variable "monitoring_slack_api_key" {
  type = string
}
