terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-cires-ac-terraform-up-and-running"
    key            = "prod/services/data-stores/mysql/terraform.tfstate"
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

variable "db_password" {
  description = "The password of the database"
  type = string
  sensitive = true
}

module "mysql" {
  source = "../../../../modules/services/data-stores/mysql"

  db_identifier = "my-sql-prod"
  db_instance_class = "db.t3.micro"

  db_name     = "proddb"
  db_password = var.db_password
  db_username = var.db_username
}