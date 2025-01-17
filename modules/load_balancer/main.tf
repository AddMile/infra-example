resource "google_compute_region_network_endpoint_group" "main" {
  region = var.region

  network_endpoint_type = "SERVERLESS"
  name                  = "${var.service_name}-neg-${var.region}"

  cloud_run {
    service = var.service_name
  }
}

resource "google_compute_ssl_policy" "main" {
  name            = "${var.name}-ssl-policy"
  min_tls_version = "TLS_1_2"
  profile         = "MODERN"
}

module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 11.1"

  project = var.project_id
  name    = var.name

  ssl                             = true
  ssl_policy                      = google_compute_ssl_policy.main.self_link
  managed_ssl_certificate_domains = var.domains
  https_redirect                  = true

  backends = {
    default = {

      protocol   = "HTTP"
      enable_cdn = false

      iap_config = {
        enable = false
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group = google_compute_region_network_endpoint_group.main.id
        }
      ]
    }
  }

  depends_on = [
    google_compute_region_network_endpoint_group.main,
    google_compute_ssl_policy.main,
  ]
}
