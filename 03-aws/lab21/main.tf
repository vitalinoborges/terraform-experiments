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
  user_data     = file("script.sh")

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
  user_data     = file("script.sh")


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


resource "aws_security_group" "default" {
  name        = "terraform-default-sg-2"
  description = "Default SG to alllow traffic from the VPC"
  vpc_id      = module.aws_vpc.vpc_id

  depends_on = [
    module.aws_vpc.vpc
  ]

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "8"
    to_port     = "0"
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "terraform"
  }
}

resource "aws_elb" "bar" {
  name            = "terraform-elb"
  subnets         = [module.aws_vpc.private_subnet_id, module.aws_vpc.public_subnet_id]
  security_groups = [aws_security_group.default.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = [aws_instance.app_server_02.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "terraform-elb"
  }
}

output "name" {
  value = aws_elb.bar.dns_name
}