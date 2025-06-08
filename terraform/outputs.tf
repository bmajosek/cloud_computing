output "instance_ip" {
  value = google_compute_instance.app_instance.network_interface[0].access_config[0].nat_ip
}

output "cloudsql_private_ip" {
  value = google_sql_database_instance.default.ip_address[0].ip_address
}
