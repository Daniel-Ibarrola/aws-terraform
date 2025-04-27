terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Applicant Tracking System qa VPC"
  }
}

resource "aws_subnet" "ats-public-subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "ats-public-subnet"
  }
}

resource "aws_subnet" "ats-private-subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "ats-private-subnet_a"
  }
}

resource "aws_subnet" "ats-private-subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "ats-private-subnet_b"
  }
}

resource "aws_subnet" "ats-private-subnet_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-2c"

  tags = {
    Name = "ats-private-subnet_c"
  }
}

resource "aws_internet_gateway" "ats-internet-gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "ats-internet-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ats-internet-gateway.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public-subnet-association" {
  subnet_id      = aws_subnet.ats-public-subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private-subnet-association-a" {
  subnet_id      = aws_subnet.ats-private-subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private-subnet-association-b" {
  subnet_id      = aws_subnet.ats-private-subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private-subnet-association-c" {
  subnet_id      = aws_subnet.ats-private-subnet_c.id
  route_table_id = aws_route_table.private_route_table.id
}