resource "google_cloud_run_v2_service" "main" {
  name     = var.name
  location = var.region
  ingress  = var.ingress

  template {
    service_account = var.service_account

    scaling {
      min_instance_count = var.min_instance_count
      max_instance_count = var.max_instance_count
    }

    volumes {
      name = var.db_volume_name
      cloud_sql_instance {
        instances = [var.db_instance_connection_name]
      }
    }

    containers {
      image = var.image
      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
        cpu_idle = true
      }
      ports {
        container_port = 8080
      }

      # not sure why do we need this one, but official tf doc says so
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service#example-usage---cloudrunv2-service-sql
      volume_mounts {
        name       = var.db_volume_name
        mount_path = "/${var.db_volume_name}"
      }
    }

    vpc_access {
      connector = var.vpc_access_connector_id
      egress    = "ALL_TRAFFIC"
    }
  }

  lifecycle {
    ignore_changes = [
      # env vars are set through app deployment
      template[0].containers[0].env,
      # deploy goes through gcloud SDK and github actions, that applies two custom labels
      # 'sha-commit' and 'managed-by'
      template[0].labels,
      # set by gcloud
      client,
      # set by gcloud
      client_version,
    ]
  }
}

# the service itself is hidden behind VPC, so we seems safe here
resource "google_cloud_run_service_iam_member" "main" {
  service  = google_cloud_run_v2_service.main.name
  location = google_cloud_run_v2_service.main.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
