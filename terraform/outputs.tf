output "instance_ip" {
  value = google_compute_instance.app_instance.network_interface[0].access_config[0].nat_ip
}

output "cloudsql_private_ip" {
  value = google_sql_database_instance.default.ip_address[0].ip_address
}

output "cloudsql_connection_name" {
  value = google_sql_database_instance.default.connection_name
}

output "database_connection_details" {
  value = {
    host     = google_sql_database_instance.default.private_ip_address
    name     = var.db_name
    user     = var.db_user
    password = var.db_password # Marked sensitive to hide in output
  }
  sensitive = true
}