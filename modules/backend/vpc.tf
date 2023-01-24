
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  subnet_count = 3
}

resource "aws_vpc" "main" {
  cidr_block       = var.subnet_cidr_block
  instance_tenancy = "default"

  tags = {
    Name                                 = "EKS Stack"
  }
}

resource "aws_subnet" "eks_subnet" {
  count                   = local.subnet_count
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  tags = {
    Name                                 = "EKS Stack"
    "kubernetes.io/cluster/main_cluster" = "shared"
    "kubernetes.io/role/elb"             = 1
    "kubernetes.io/role/internal-elb"    = ""
  }
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.subnet_cidr_block, 7, count.index)
}

# aws_route_table_association public subnets
resource "aws_route_table_association" "eks_route_table_association" {
  count          = local.subnet_count
  subnet_id      = element(aws_subnet.eks_subnet.*.id, count.index)
  route_table_id = aws_route_table.eks_route_table.id
}

// Internet Gateway
resource "aws_internet_gateway" "eks_internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name                                 = "EKS Stack"
  }
}

// Route Table
resource "aws_route_table" "eks_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_internet_gateway.id
  }

  tags = {
    Name                                 = "EKS Stack"
  }
}

// DHCP
resource "aws_vpc_dhcp_options" "eks_vpc_dhcp_options" {
  domain_name = "gorilla.local"
  domain_name_servers = [
    "AmazonProvidedDNS",
    "1.1.1.1",
    "8.8.8.8",
  ]
  ntp_servers = [
    "45.11.105.223",
    "194.0.5.123",
    "200.89.75.198",
    "45.11.105.243"
  ]

  tags = {
    Name = "DHCP Options gorilla"
  }
}

// DHCP association
resource "aws_vpc_dhcp_options_association" "eks_vpc_dhcp_options_association" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.eks_vpc_dhcp_options.id
}