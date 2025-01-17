output "network_id" {
  value = google_compute_network.main.id
}

output "subnetwork_name" {
  value = google_compute_subnetwork.main.name
}

output "access_connector_id" {
  value = google_vpc_access_connector.main.id
}
