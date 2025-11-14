variable "db_host" {
  description = "The hostname or endpoint of the Postgres database"
  type        = string
}

variable "db_user" {
  description = "Database username"
  type        = string
}

variable "db_pass" {
  description = "Database password"
  type        = string
  sensitive   = true
}

