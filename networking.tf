resource "aws_vpc" "vpc_example" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_example.id
}

resource "aws_subnet" "public" {
  for_each                = var.subnet_public
  vpc_id                  = aws_vpc.vpc_example.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  for_each          = var.subnet_private
  vpc_id            = aws_vpc.vpc_example.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
}

resource "aws_subnet" "database" {
  for_each          = var.subnet_database
  vpc_id            = aws_vpc.vpc_example.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
}

resource "aws_eip" "eip_natgw" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_natgw.id
  subnet_id     = values(aws_subnet.public)[0].id
}

resource "aws_route_table" "route_public" {
  vpc_id = aws_vpc.vpc_example.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "route_private" {
  vpc_id = aws_vpc.vpc_example.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_public.id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_private.id

}