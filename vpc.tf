resource "aws_vpc" "tk_tf_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.demo}-vpc"
    Environment = "${var.demo}"
  }
}

resource "aws_internet_gateway" "tk_tf_igw" {
  vpc_id = aws_vpc.tk_tf_vpc.id

  tags = {
    Name        = "${var.demo}-igw"
    Environment = "${var.demo}"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.tk_tf_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.demo}-public-subnet-1a"
    Environment = "${var.demo}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.tk_tf_vpc.id
  tags   = { Name = "${var.demo}-tf-public-route-table" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tk_tf_igw.id
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}