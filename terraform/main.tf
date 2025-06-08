# ------------------------------
# Enable Required APIs
# ------------------------------
resource "google_project_service" "required_apis" {
  for_each = toset([
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "iam.googleapis.com"
  ])
  
  service            = each.key
  disable_on_destroy = false

  # Give APIs time to fully enable
  provisioner "local-exec" {
    command = "sleep 90"
  }
}

# ------------------------------
# VPC + Subnet
# ------------------------------
resource "google_compute_network" "vpc" {
  name                    = "django-vpc"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.required_apis]
}

resource "google_compute_subnetwork" "subnet" {
  name          = "django-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# ------------------------------
# Cloud SQL PostgreSQL
# ------------------------------
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "cloudsql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
  
  depends_on = [
    google_project_service.required_apis,
    google_compute_global_address.private_ip_alloc
  ]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "default" {
  name             = "django-sql-${random_id.db_name_suffix.hex}"
  region           = var.region
  database_version = "POSTGRES_14"
  depends_on       = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }

    backup_configuration {
      enabled = true
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "app_db" {
  name     = var.db_name
  instance = google_sql_database_instance.default.name
}

resource "google_sql_user" "django_user" {
  name     = var.db_user
  instance = google_sql_database_instance.default.name
  password = var.db_password
}

# ------------------------------
# Compute Instance (Django App)
# ------------------------------
resource "google_compute_instance" "app_instance" {
  name         = "instagram-demo"
  machine_type = "e2-standard-2"
  zone         = var.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork    = google_compute_subnetwork.subnet.id
    access_config {}  # Optional: allows external internet access
  }

  metadata_startup_script = file("startup.sh")

  tags = ["http-server"]

  service_account {
    email  = google_service_account.django_sa.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    google_project_service.required_apis,
    google_compute_subnetwork.subnet
  ]
}

# ------------------------------
# Firewall Rules
# ------------------------------
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-ports"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8000", "8001", "8002", "8003", "8005"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # Restrict this to your IP in production
}

# ------------------------------
# Service Account for App
# ------------------------------
resource "google_service_account" "django_sa" {
  account_id   = "django-sa"
  display_name = "Django App Service Account"
  depends_on   = [google_project_service.required_apis]
}

# ------------------------------
# IAM Roles for Service Account
# ------------------------------
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.django_sa.email}"
}