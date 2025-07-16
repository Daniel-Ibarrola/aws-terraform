terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.3.0"
    }
  }
}

ephemeral "random_password" "db_password" {
  length           = 16
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_password" {
  name = var.db_password_secret_name
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id                = aws_secretsmanager_secret.db_password.id
  secret_string_wo         = ephemeral.random_password.db_password.result
  secret_string_wo_version = 1
}

ephemeral "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret_version.db_password.secret_id
}

resource "aws_db_instance" "mysql" {
  identifier_prefix = var.db_identifier
  engine = "mysql"
  allocated_storage = 10
  skip_final_snapshot = true
  instance_class = var.db_instance_class
  db_name = var.db_name

  username = var.db_username
  password_wo         = ephemeral.aws_secretsmanager_secret_version.db_password.secret_string
  password_wo_version = aws_secretsmanager_secret_version.db_password.secret_string_wo_version
}