resource "google_compute_instance" "app_instance" {
  name         = "instagram-demo"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("startup.sh")

  tags = ["http-server"]
}

resource "google_compute_firewall" "default" {
  name    = "allow-http-ports"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8000", "8001", "8002", "8003", "8005"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}