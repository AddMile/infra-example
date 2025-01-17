resource "google_monitoring_notification_channel" "slack_alert" {
  project      = var.project_id
  display_name = "backend alerts"
  type         = "slack"
  labels = {
    channel_name = var.slack_channel
  }
  sensitive_labels {
    auth_token = var.slack_api_key
  }
}

resource "google_monitoring_alert_policy" "error_alert_policy" {
  project      = var.project_id
  display_name = "Error Log"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "error occurred"
    condition_matched_log {
      filter = "resource.type=\"cloud_run_revision\" AND severity>=ERROR"
    }
  }

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
    auto_close = "1800s"
  }

  notification_channels = [google_monitoring_notification_channel.slack_alert.id]
}
