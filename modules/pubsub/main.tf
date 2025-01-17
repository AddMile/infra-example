locals {
  topic_subs = flatten([
    for topic, details in var.topic_subs : [
      for sub in details.subscriptions : {
        topic         = topic
        sub           = sub.name
        push_endpoint = sub.push_endpoint
        key           = "${topic}-${sub.name}"
      }
    ]
  ])
}

resource "google_pubsub_topic" "main" {
  for_each = var.topic_subs

  name = each.key
}

resource "google_pubsub_topic" "dead_letter" {
  for_each = var.topic_subs

  name = "dead.${each.key}"

  depends_on = [
    google_pubsub_topic.main,
  ]
}

resource "google_pubsub_subscription" "main" {
  for_each = { for ts in local.topic_subs : ts.key => ts }

  name  = each.value.sub
  topic = google_pubsub_topic.main[each.value.topic].name

  message_retention_duration = "1200s"
  retain_acked_messages      = true
  ack_deadline_seconds       = 20

  push_config {
    push_endpoint = "${var.push_host}${each.value.push_endpoint}"
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter[each.value.topic].id
    max_delivery_attempts = 5
  }

  retry_policy {
    minimum_backoff = "5s"
  }

  depends_on = [
    google_pubsub_topic.main,
    google_pubsub_topic.dead_letter,
  ]
}

resource "google_pubsub_subscription" "dead_letter" {
  for_each = var.topic_subs

  name  = "sub.${google_pubsub_topic.dead_letter[each.key].name}"
  topic = google_pubsub_topic.dead_letter[each.key].id

  depends_on = [
    google_pubsub_topic.dead_letter,
  ]
}

// Note; for some reason google forces us to use their default service account for pub/sub
// IAM topics and subs
resource "google_pubsub_topic_iam_member" "publish" {
  for_each = var.topic_subs

  topic  = google_pubsub_topic.main[each.key].id
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${var.pubsub_sa}"

  depends_on = [
    google_pubsub_topic.main,
  ]
}

resource "google_pubsub_subscription_iam_member" "subscribe" {
  for_each = { for ts in local.topic_subs : ts.key => ts }

  subscription = each.value.sub
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${var.pubsub_sa}"

  depends_on = [
    google_pubsub_subscription.main,
  ]
}

// IAM dead_letter topics and subs
resource "google_pubsub_topic_iam_member" "publish_dead_letter" {
  for_each = var.topic_subs

  topic  = google_pubsub_topic.dead_letter[each.key].id
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${var.pubsub_sa}"

  depends_on = [
    google_pubsub_topic.dead_letter,
  ]
}

resource "google_pubsub_subscription_iam_member" "subscribe_dead_letter" {
  for_each = var.topic_subs

  subscription = "sub.${google_pubsub_topic.dead_letter[each.key].name}"
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${var.pubsub_sa}"

  depends_on = [
    google_pubsub_subscription.dead_letter,
  ]
}
