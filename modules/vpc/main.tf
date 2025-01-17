resource "google_compute_network" "main" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = google_compute_network.main.name
  region        = var.region
  ip_cidr_range = "10.2.0.0/28"
  network       = google_compute_network.main.id
}

resource "google_vpc_access_connector" "main" {
  name   = var.vpc_access_connector_name
  region = var.region

  subnet {
    name = var.vpc_subnetwork_name
  }

  machine_type  = var.vpc_access_connector_machine_type
  min_instances = var.vpc_access_connector_min_instances
  max_instances = var.vpc_access_connector_max_instances

  lifecycle {
    ignore_changes = [
      # has to ignore max_throughput, since on every deploy the value changes between 300-4000 on f1-micro
      max_throughput,
    ]
  }
}

# egress through statis IP address
resource "google_compute_router" "main" {
  provider = google-beta
  name     = "backend-static-ip-router"
  network  = google_compute_network.main.name
  region   = google_compute_subnetwork.main.region
}

resource "google_compute_address" "main" {
  provider = google-beta
  name     = "backend-static-ip-addr"
  region   = google_compute_subnetwork.main.region
}

resource "google_compute_router_nat" "main" {
  provider = google-beta
  name     = "backend-static-nat"
  router   = google_compute_router.main.name
  region   = google_compute_subnetwork.main.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.main.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.main.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
