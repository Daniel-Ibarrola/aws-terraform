terraform {
  backend "s3" {
    bucket         = "terraform-state-cires-ac-terraform-up-and-running"
    key            = "stage/services/data-stores/mysql/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}


variable "db_username" {
  description = "The username of the database"
  type = string
  sensitive = true
}

module "mysql" {
  source = "../../../../modules/services/data-stores/mysql"

  db_identifier = "my-sql-stage"
  db_instance_class = "db.t3.micro"

  db_name     = "test"
  db_username = var.db_username
  db_password_secret_name = "my-sql-stage-password"
}