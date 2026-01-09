variable "name" {
  type        = string
  description = "Name prefix"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the DB subnet group"
}

variable "db_sg_id" {
  type        = string
  description = "Security group ID attached to the DB"
}

variable "db_name" {
  type        = string
  description = "Database name (e.g. umami)"
}

variable "db_username" {
  type        = string
  description = "Master username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Master password"
}

