variable "db_username" {
  description = "The username of the database"
  type = string
  sensitive = true
}

variable "db_identifier" {
  description = "An identifier for the database"
  type = string
}

variable "db_name" {
  description = "The name of the database to create"
  type = string
}

variable "db_instance_class" {
  description = "The instance type that will run the database e.g 'db.t3.micro'"
  type = string
}

variable "db_password_secret_name" {
  description = "The name of the secret that stores the database password"
  type = string
}