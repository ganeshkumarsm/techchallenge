#----networking/main.tf -----

#Here we are few additional stuffs:
# 1. Randle Shuffle is used to get the list of random availability zones and couple it with the public and private subnets.
# 2. Dynamically create the Ingress rules for the public security group using Dynamic block.


data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "random_shuffle" "shuffle_availabilityzones" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}
resource "aws_vpc" "ganesh_vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ganesh-vpc-${random_integer.random.id}"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_internet_gateway" "ganesh_igw" {
  vpc_id = aws_vpc.ganesh_vpc.id

  tags = {
    Name = "internetgateway"
  }
}

resource "aws_route_table" "ganesh_public_route_table" {
  vpc_id = aws_vpc.ganesh_vpc.id

  tags = {
    Name = "public_routetable"
  }

}

resource "aws_route" "ganesh_public_route" {
  route_table_id         = aws_route_table.ganesh_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ganesh_igw.id

}

resource "aws_subnet" "ganesh_public_subnet" {
  count                   = var.public_sn_count
  availability_zone       = random_shuffle.shuffle_availabilityzones.result[count.index]
  cidr_block              = var.public_cidrs[count.index]
  vpc_id                  = aws_vpc.ganesh_vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "ganesh_public_subnet_${count.index + 1}"
  }
}

resource "aws_subnet" "ganesh_private_subnet" {
  count                   = var.private_sn_count
  availability_zone       = random_shuffle.shuffle_availabilityzones.result[count.index]
  cidr_block              = var.private_cidrs[count.index]
  vpc_id                  = aws_vpc.ganesh_vpc.id
  map_public_ip_on_launch = false

  tags = {
    Name = "ganesh_private_subnet_${count.index + 1}"
  }
}

resource "aws_default_route_table" "ganesh_default_private_rt" {

  default_route_table_id = aws_vpc.ganesh_vpc.default_route_table_id
}

resource "aws_route_table_association" "public_sn_rt" {

  count          = var.public_sn_count
  subnet_id      = aws_subnet.ganesh_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.ganesh_public_route_table.id
}

resource "aws_security_group" "ganesh_ingress_sg" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.ganesh_vpc.id

  dynamic "ingress" {
    for_each = each.value.ingress

    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_db_subnet_group" "ganesh_rds_subnet_group" {
  count      = 1
  name       = "rds_subnet_group"
  subnet_ids = aws_subnet.ganesh_private_subnet.*.id


  tags = {
    Name = "My DB subnet group"
  }
}