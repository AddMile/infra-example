resource "google_service_account" "main" {
  account_id   = var.service_account_name
  display_name = var.service_account_display_name
}

resource "google_service_account_key" "main" {
  service_account_id = google_service_account.main.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_project_iam_member" "main" {
  for_each = var.service_account_roles

  project = var.project_id
  role    = each.value

  member = "serviceAccount:${google_service_account.main.email}"
}

