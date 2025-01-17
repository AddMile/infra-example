resource "google_compute_global_address" "main" {
  name          = "cloudsql-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_network_id
}

resource "google_service_networking_connection" "main" {
  network                 = var.vpc_network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.main.name]
}

resource "google_sql_database_instance" "main" {
  region = var.region

  name             = var.name
  database_version = var.database_version

  deletion_protection = var.deletion_protection

  settings {
    tier = var.tier

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.vpc_network_id
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    backup_configuration {
      enabled = var.backup_enabled
    }

    insights_config {
      query_insights_enabled  = var.query_insights_enabled
      query_string_length     = 1024
      record_application_tags = false
      record_client_address   = false
    }
  }

  depends_on = [
    google_service_networking_connection.main
  ]
}

resource "google_sql_database" "main" {
  project = var.project_id

  name     = var.db_name
  instance = google_sql_database_instance.main.name

  depends_on = [
    google_sql_database_instance.main
  ]
}

resource "google_sql_user" "main" {
  project = var.project_id

  instance = google_sql_database_instance.main.name
  name     = var.db_user
  password = var.db_password

  depends_on = [
    google_sql_database_instance.main
  ]
}
