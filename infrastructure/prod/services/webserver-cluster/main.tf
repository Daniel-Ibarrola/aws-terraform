provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      Owner = "avengers"
      ManagedBy = "terraform"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-cires-ac-terraform-up-and-running"
    key            = "prod/services/webserver-cluster/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  db_remote_state_bucket = "terraform-state-cires-ac-terraform-up-and-running"
  db_remote_state_key = "prod/services/data-stores/mysql/terraform.tfstate"

  cluster_name = "cluster-prod"
  instance_type = "t3.small"
  min_size = 2
  max_size = 3

  enable_autoscaling = true

  custom_tags = {
    Owner = "avengers"
    ManagedBy = "terraform"
  }
}

