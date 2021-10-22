resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr //"10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    name = "sat-vpc"
    environment = var.env
  }
}
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw-${var.env}"
    environment = var.env
  }
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}

resource "aws_nat_gateway" "nat" {
    
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id,0)
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name = "nat-${var.env}"
    environment = var.env

  }
}

resource "aws_subnet" "public_subnet" {
  count = "${length(data.aws_availability_zones.available.names)-1}"
  vpc_id = aws_vpc.vpc.id

  #cidr_block              = "10.0.1.0/24"
  #cidr_block = "10.0.${10+count.index}.0/24"
  cidr_block = var.public_subnet_cidr_blocks[count.index]
 # availability_zone       = "ap-south-1a"
 availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${var.env}"
    environment = var.env

  }
}

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.vpc.id

  cidr_block              = var.private_subnet_cidr //"10.0.10.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-${var.env}"
    environment = var.env

  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private-route-table-${var.env}"
    environment = var.env

  }
}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "public-route-table-${var.env}"
    environment = var.env

  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

/* Route table associations */
resource "aws_route_table_association" "public" {

  count = "${length(data.aws_availability_zones.available.names)-1}"
  subnet_id      = element(aws_subnet.public_subnet.*.id,count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {

  subnet_id      = element(aws_subnet.private_subnet.*.id, 0)
  route_table_id = aws_route_table.private.id
}

output "vpc_Id" {
    value = "${aws_vpc.vpc.id}"
}

output "pub_sub_Id" {
    value = "${aws_subnet.public_subnet}"
}

output "privt_sub_Id" {
    value = "${aws_subnet.private_subnet.id}"
}

output "sbnts_id" {
    value = "${aws_subnet.public_subnet.*.id}"
}