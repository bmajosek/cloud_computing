variable "project_id" { default = "instagram-clone-462218" }
variable "region"     { default = "europe-central2" }
variable "zone"       { default = "europe-central2-a" }
variable "db_name" {
  default = "app_db"
}

variable "db_user" {
  default = "django_user"
}

variable "db_password" {
  description = "Database password"
  default = "1234"
  sensitive   = true
}