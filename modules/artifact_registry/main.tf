resource "google_artifact_registry_repository" "main" {
  location      = var.region
  repository_id = var.repository_name
  format        = "DOCKER"
}
