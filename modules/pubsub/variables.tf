variable "pubsub_sa" {
  type = string
}

variable "push_host" {
  type = string
}

variable "topic_subs" {
  type = map(object({
    subscriptions = list(object({
      name          = string
      push_endpoint = string
    }))
  }))
}

