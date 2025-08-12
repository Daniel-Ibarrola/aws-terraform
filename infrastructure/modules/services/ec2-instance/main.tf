terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100"
    }
  }
  required_version = ">= 1.0"
}

variable "ami" {
  type = string
  description = "The AMI the instance will use"
}

resource "aws_security_group" "allow_http_and_ssh" {
  name        = "Web Server SG"
  description = "Allow http and ssh traffic from anywhere"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "webserver" {
  ami           = var.ami
  instance_type = "t2.micro"

  user_data = file("${path.module}/user-data.sh")

  security_groups = [aws_security_group.allow_http_and_ssh.name]
}