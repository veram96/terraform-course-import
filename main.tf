###

# Aquí existe más configuración que no puedes destruir
# con el comando terraform destroy

###

locals {
  prefix = "jboss"
}

resource "google_compute_network" "vpc_network" {
  name                            = "target-vpc"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = "${local.prefix}-subnetwork"
  ip_cidr_range = "10.10.1.0/24"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_instance" "instance" {
  name         = "${local.prefix}-instance"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = "10"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnetwork.id
    access_config {
      // Ephemeral public IP
    }
  }
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    scopes = ["cloud-platform"]
  }
  lifecycle {
    ignore_changes = [metadata["ssh-keys"]]
  }
}
