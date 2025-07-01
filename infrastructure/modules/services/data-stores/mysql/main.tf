terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100"
    }
  }
}

resource "aws_db_instance" "mysql" {
  identifier_prefix = var.db_identifier
  engine = "mysql"
  allocated_storage = 10
  skip_final_snapshot = true
  instance_class = var.db_instance_class
  db_name = var.db_name

  username = var.db_username
  password = var.db_password
}