terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Fetch available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
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

resource "aws_subnet" "ats-private-subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  # Cycle through available AZs; ensure you have enough AZs for your subnet count
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = {
    Name = "ats-private-subnet-${count.index}"
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

resource "aws_route_table_association" "private-subnet-association" {
  count          = length(aws_subnet.ats-private-subnet)
  subnet_id      = aws_subnet.ats-private-subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}