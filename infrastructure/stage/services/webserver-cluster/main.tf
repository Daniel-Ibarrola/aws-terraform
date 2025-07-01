terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-cires-ac-terraform-up-and-running"
    key            = "stage/services/webserver-cluster/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  db_remote_state_bucket = "terraform-state-cires-ac-terraform-up-and-running"
  db_remote_state_key = "stage/services/data-stores/mysql/terraform.tfstate"

  cluster_name = "webserver-cluster-stage"
  instance_type = "t3.micro"
  min_size = 1
  max_size = 2
}