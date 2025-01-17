resource "google_cloud_scheduler_job" "main" {
  for_each    = { for job in var.jobs : job.name => job }
  name        = each.value.name
  description = each.value.description
  schedule    = each.value.schedule
  time_zone   = each.value.time_zone

  retry_config {
    retry_count = each.value.retry_count
  }

  pubsub_target {
    topic_name = "projects/${var.project_id}/topics/${each.value.topic}"
    data       = base64encode(jsonencode(each.value.data))
  }
}
