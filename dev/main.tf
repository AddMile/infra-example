resource "google_project_service" "main" {
  for_each = var.google_apis

  service            = each.value
  disable_on_destroy = false
}

resource "google_storage_bucket" "terraform_state" {
  name     = var.state_bucket
  location = var.region

  lifecycle {
    prevent_destroy = true
  }

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "google_secret_manager_secret" "env" {
  secret_id = "example-env"
  replication {
    auto {}
  }

  depends_on = [
    google_project_service.main
  ]
}

module "deploy_iam" {
  source = "../../modules/iam"

  project_id                   = var.project_id
  service_account_name         = var.deploy_service_account_name
  service_account_display_name = var.deploy_service_account_display_name
  service_account_roles        = var.deploy_service_account_roles

  depends_on = [
    google_project_service.main
  ]
}

module "runtime_iam" {
  source = "../../modules/iam"

  project_id                   = var.project_id
  service_account_name         = var.runtime_service_account_name
  service_account_display_name = var.runtime_service_account_display_name
  service_account_roles        = var.runtime_service_account_roles

  depends_on = [
    google_project_service.main
  ]
}

module "artifact_registry" {
  source = "../../modules/artifact_registry"

  project_id      = var.project_id
  region          = var.region
  repository_name = var.artifact_registry_repository_name

  depends_on = [
    google_project_service.main
  ]
}

module "vpc" {
  source = "../../modules/vpc"

  region       = var.region
  network_name = var.vpc_network_name

  vpc_subnetwork_name                = module.vpc.subnetwork_name
  vpc_access_connector_name          = var.vpc_access_connector_name
  vpc_access_connector_machine_type  = var.vpc_access_connector_machine_type
  vpc_access_connector_min_instances = var.vpc_access_connector_min_instances
  vpc_access_connector_max_instances = var.vpc_access_connector_max_instances

  depends_on = [
    google_project_service.main
  ]
}

module "cloud_sql" {
  source = "../../modules/cloud_sql"

  project_id = var.project_id
  region     = var.region

  name                = var.db_instance_name
  database_version    = var.db_version
  deletion_protection = var.db_deletion_protection
  tier                = var.db_tier
  vpc_network_id      = module.vpc.network_id

  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password

  backup_enabled         = var.db_backup_enabled
  query_insights_enabled = var.db_query_insights_enabled

  depends_on = [
    google_project_service.main,
    module.vpc,
  ]
}

module "api" {
  source = "../../modules/cloud_run"

  region = var.region

  ingress                 = var.api_ingress
  vpc_access_connector_id = module.vpc.access_connector_id

  name               = var.api_name
  image              = "${module.artifact_registry.repository}/${var.api_image_name}:latest"
  min_instance_count = var.api_min_instance_count
  max_instance_count = var.api_max_instance_count

  db_volume_name              = var.db_volume_name
  db_instance_connection_name = module.cloud_sql.instance

  service_account = "${var.runtime_service_account_name}@${var.project_id}.iam.gserviceaccount.com"

  depends_on = [
    google_project_service.main,
    module.deploy_iam,
    module.runtime_iam,
    module.vpc,
    module.artifact_registry,
    module.cloud_sql,
  ]
}

module "worker" {
  source = "../../modules/cloud_run"

  region = var.region

  ingress                 = var.worker_ingress
  vpc_access_connector_id = module.vpc.access_connector_id

  name               = var.worker_name
  image              = "${module.artifact_registry.repository}/${var.worker_image_name}:latest"
  min_instance_count = var.worker_min_instance_count
  max_instance_count = var.worker_max_instance_count

  db_volume_name              = var.db_volume_name
  db_instance_connection_name = module.cloud_sql.instance

  service_account = "${var.runtime_service_account_name}@${var.project_id}.iam.gserviceaccount.com"

  depends_on = [
    google_project_service.main,
    module.deploy_iam,
    module.runtime_iam,
    module.vpc,
    module.artifact_registry,
    module.cloud_sql,
  ]
}

module "load_balancer" {
  source = "../../modules/load_balancer"

  project_id = var.project_id
  region     = var.region

  name         = var.load_balancer_name
  service_name = var.api_name
  domains      = var.example_api_domains

  depends_on = [
    module.api,
  ]
}

module "pubsub" {
  source = "../../modules/pubsub"

  pubsub_sa  = "service-${var.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com"
  topic_subs = var.topic_subs
  push_host  = module.worker.uri

  depends_on = [
    google_project_service.main,
    module.worker,
  ]
}

module "cloud_scheduler" {
  source = "../../modules/cloud_scheduler"

  project_id = var.project_id
  jobs       = var.jobs

  depends_on = [
    google_project_service.main,
    module.pubsub,
  ]
}

module "alert" {
  source = "../../modules/alert"

  project_id    = var.project_id
  slack_channel = var.monitoring_slack_channel
  slack_api_key = var.monitoring_slack_api_key
}
