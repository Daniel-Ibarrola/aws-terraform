# Fetch available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "servicios_cires_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Servicios Cires VPC"
    Env = local.env
  }
}

resource "aws_subnet" "servicios-cires-public-subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.servicios_cires_vpc.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = true

  tags = {
    Name = "servicios-cires-public-subnet-${count.index}"
    Env = local.env
  }
}

resource "aws_subnet" "servicios-cires-private-subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.servicios_cires_vpc.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = {
    Name = "servicios-cires-private-subnet-${count.index}"
    Env = local.env
  }
}

resource "aws_internet_gateway" "servicios-cires-internet-gateway" {
  vpc_id = aws_vpc.servicios_cires_vpc.id
  tags = {
    Name = "servicios-cires-internet-gateway"
    Env = local.env
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.servicios_cires_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.servicios-cires-internet-gateway.id
  }

  tags = {
    Name = "public-route-table"
    Env = local.env
  }
}

resource "aws_route_table_association" "public-subnet-association" {
  count          = length(aws_subnet.servicios-cires-public-subnet)
  subnet_id      = aws_subnet.servicios-cires-public-subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.servicios_cires_vpc.id

  tags = {
    Name = "private-route-table"
    Env = local.env
  }
}

resource "aws_route_table_association" "private-subnet-association" {
  count          = length(aws_subnet.servicios-cires-private-subnet)
  subnet_id      = aws_subnet.servicios-cires-private-subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}