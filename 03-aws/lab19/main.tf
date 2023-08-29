terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.17.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "terraform-vpc"
    Environment = "terraform"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "terraform-igw"
    Environment = "terraform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "terraform-public-route-table"
    Environment = "terraform"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "terraform-us-east-1a-public-subnet"
    Environment = "terraform"
  }
}

resource "aws_security_group" "default" {
  name        = "terraform-default-sg"
  description = "Default SG to alllow traffic from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }

  tags = {
    Environment = "terraform"
  }
}

#resource "aws_subnet" "private_subnet" {
#  vpc_id                  = aws_vpc.vpc.id
#  cidr_block              = "192.168.1.0/24"
#  availability_zone       = "us-east-1b"
#  map_public_ip_on_launch = false

#  tags = {
#    Name        = "terraform-us-east-1b-private-subnet"
#    Environment = "terraform"
#  }
#}

resource "aws_network_interface" "ubuntu_vnic" {
  subnet_id       = aws_subnet.public_subnet.id
  private_ips     = ["192.168.0.10"]
  security_groups = [aws_security_group.default.id]

  tags = {
    Name = "primary_network_interface"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "novo.vitalinoficial"

  tags = {
    Name = "terraform_ec2_instance"
  }

  network_interface {
    network_interface_id = aws_network_interface.ubuntu_vnic.id
    device_index         = 0
  }
}

output "public_ip" {
  value = aws_instance.app_server.public_ip
}