terraform {
  backend "s3" {
    bucket         = "terraform-state-cires-ac-terraform-up-and-running"
    key            = "workspaces/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
  alias = "us-east-region"
}

provider "aws" {
  region = "us-west-1"
  alias = "us-west-region"
}

module "ec2_instance_us_east" {
  source = "../../../modules/services/ec2-instance"

  providers = {
    aws = aws.us-east-region
  }

  ami = "ami-0de716d6197524dd9"
}

module "ec2_instance_us_west" {
  source = "../../../modules/services/ec2-instance"

  providers = {
    aws = aws.us-west-region
  }

  ami = "ami-06e11c4cc68c362dd"
}