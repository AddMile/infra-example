terraform {
  backend "gcs" {
    bucket = "project-dev-example-terraform-state"
  }
}

