resource "google_storage_bucket" "main" {
  name     = var.name
  location = var.location

  uniform_bucket_level_access = true

  labels = {
    service = var.label_service
  }


  versioning {
    enabled = var.versioning_enabled
  }

  lifecycle {
    prevent_destroy = true
  }
}

# publicly readable object is cached in the global Cloud Storage network
resource "google_storage_bucket_iam_binding" "public" {
  count   = var.public_access ? 1 : 0
  bucket  = google_storage_bucket.main.name
  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}

