
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "stage-vpc"
  }
}

#IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "stage-igw"
  }
}

#subnets
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(data.aws_availability_zones.available.names)
  cidr_block              = element(var.public_cidr, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "stage-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(data.aws_availability_zones.available.names)
  cidr_block        = element(var.pvt_cidr, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  #map_public_ip_on_launch = true 

  tags = {
    Name = "stage-private-${count.index + 1}"
  }
}
resource "aws_subnet" "data" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(data.aws_availability_zones.available.names)
  cidr_block        = element(var.data_cidr, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  #map_public_ip_on_launch = true 

  tags = {
    Name = "stage-data-${count.index + 1}"
  }
}
#Nat-gw
#EIP
resource "aws_eip" "eip" {
  vpc = true
  tags = {
    Name = "Stage EIP"
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "Stage NAT-GW"
  }
  depends_on = [
    aws_eip.eip
  ]
}
#route Tables

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Stage-Public-Route"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "Stage-Private-Route"
  }
}
#Associate

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "data" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.data[*].id, count.index)
  route_table_id = aws_route_table.private.id
}