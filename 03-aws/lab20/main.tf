module "aws_vpc" {
  source = "./aws_vpc"
}

resource "aws_network_interface" "ubuntu_vnic" {
  subnet_id       = module.aws_vpc.public_subnet_id
  private_ips     = ["192.168.0.10"]
  security_groups = [module.aws_vpc.default_security_group_id]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_network_interface" "ubuntu_vnic_02" {
  subnet_id       = module.aws_vpc.private_subnet_id
  private_ips     = ["192.168.1.10"]
  security_groups = [module.aws_vpc.default_security_group_id]

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

resource "aws_instance" "app_server_01" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "novo.vitalinoficial"

  tags = {
    Name = "terraform_ec2_instance_01"
  }

  network_interface {
    network_interface_id = aws_network_interface.ubuntu_vnic.id
    device_index         = 0
  }
}

resource "aws_instance" "app_server_02" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "novo.vitalinoficial"

  tags = {
    Name = "terraform_ec2_instance_02"
  }

  network_interface {
    network_interface_id = aws_network_interface.ubuntu_vnic_02.id
    device_index         = 0
  }
}

output "public_ip_01" {
  value = aws_instance.app_server_01.public_ip
}

output "public_ip_02" {
  value = aws_instance.app_server_02.public_ip
}