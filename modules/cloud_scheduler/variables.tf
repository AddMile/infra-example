variable "project_id" {
  type = string
}

variable "jobs" {
  type = list(object({
    name        = string
    topic       = string
    description = string
    schedule    = string
    time_zone   = string
    retry_count = number
    data        = map(any)
  }))
}
