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
