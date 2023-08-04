provider "google" {
  credentials = file(var.credentials_file)
  region      = var.region
  project     = var.project
}

provider "google-beta" {
  credentials = file(var.credentials_file)
  region      = var.region
}

#MIG

module "instance_template" {
  source             = "./modules/instance_template"
  project_id         = var.project
  network   =  google_compute_network.custom-test.id
  subnetwork         = google_compute_subnetwork.network-with-private-secondary-ip-ranges.id
  service_account    = var.service_account
  subnetwork_project = var.project
  tags               = ["instance"]

  additional_disks = [
    {
      disk_name    = "disk-0"
      device_name  = "disk-0"
      disk_size_gb = 10
      disk_type    = "pd-standard"
      auto_delete  = "true"
      boot         = "false"
      disk_labels  = {}
    },
#Uncomment to add a new disk
#    {
#      disk_name    = "newly-added-disk"
#      device_name  = "disk-1"
#      disk_size_gb = 10
#      disk_type    = "pd-standard"
#      auto_delete  = "true"
#      boot         = "false"
#      disk_labels  = {}
#    },
  ]
}

module "mig" {
  source            = "./modules/mig"
  project_id        = var.project
  region            = var.region
  target_size       = var.target_size
  hostname          = "mig-simple"
  instance_template = module.instance_template.self_link
}

#NETWORK

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.custom-test.id
  secondary_ip_range {
    range_name    = "tf-test-secondary-range-update1"
    ip_cidr_range = "192.168.10.0/24"
  }
}

resource "google_compute_network" "custom-test" {
  name   =  "test-network"
  auto_create_subnetworks = false
}

#FIREWALL

resource "google_compute_firewall" "rules" {
  project     = var.project
  name        = "my-firewall-rule"
  direction   = "INGRESS"
  network   =  google_compute_network.custom-test.id
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol = "tcp"
    ports    = ["433"]
  }
  source_tags = ["instance"]
  target_tags = ["instances-located-in-network"]
}

#LOAD BALANCER

# forwarding rule
resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  project     = var.project
  name                  = "l4-ilb-forwarding-rule"
  backend_service       = google_compute_region_backend_service.default.id
  provider              = google-beta
  region                = var.region
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  allow_global_access   = true
  network   =  google_compute_network.custom-test.id
  subnetwork = google_compute_subnetwork.network-with-private-secondary-ip-ranges.id
}

# backend service
resource "google_compute_region_backend_service" "default" {
  project     = var.project
  name                  = "l4-ilb-backend-subnet"
  provider              = google-beta
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_region_health_check.default.id]
  backend {
    group          = module.mig.instance_group
    balancing_mode = "CONNECTION"
  }
}

# health check
resource "google_compute_region_health_check" "default" {
  name     = "l4-ilb-hc"
  provider = google-beta
  project     = var.project
  region   = var.region
  http_health_check {
    port = "80"
  }
}

#allow all access from health check ranges
resource "google_compute_firewall" "fw_hc" {
  project     = var.project
  name          = "l4-ilb-fw-allow-hc"
  provider      = google-beta
  direction     = "INGRESS"
  network   =  google_compute_network.custom-test.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
  allow {
    protocol = "tcp"
  }
  source_tags = ["allow-health-check"]
}

# allow communication within the subnet
resource "google_compute_firewall" "fw_ilb_to_backends" {
  project     = var.project
  name          = "l4-ilb-fw-allow-ilb-to-backends"
  provider      = google-beta
  direction     = "INGRESS"
  network   =  google_compute_network.custom-test.id
  source_ranges = ["80.193.23.74/32"]
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
}

# allow SSH
resource "google_compute_firewall" "fw_ilb_ssh" {
  project     = var.project
  name      = "l4-ilb-fw-ssh"
  provider  = google-beta
  direction = "INGRESS"
  network   =  google_compute_network.custom-test.id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_tags = ["allow-ssh"]
}