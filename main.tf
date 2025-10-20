
provider "aws" {
  region = "eu-west-3"
}

variable "subnet_cidr_block" {}
variable "vpc_cidr_block" {}
variable "env_prefix" {}
variable "availability_zone" {}
variable "my_ip" {}
variable "instance_type" {}
variable "public_key_location" {}

resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp_subnet_1" {
  vpc_id            = aws_vpc.myapp_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_route_table" "my_app_route_table" {
  vpc_id = aws_vpc.myapp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_app_igw.id
  }

  tags = {
    Name = "${var.env_prefix}-rt"
  }
}

resource "aws_internet_gateway" "my_app_igw" {
  vpc_id = aws_vpc.myapp_vpc.id

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table_association" "myapp_subnet_assoc" {
  subnet_id      = aws_subnet.myapp_subnet_1.id
  route_table_id = aws_route_table.my_app_route_table.id
}

resource "aws_security_group" "myapp_sg" {
  name        = "myapp_sg"
  vpc_id      = aws_vpc.myapp_vpc.id

  ingress {
  from_port= 22
  protocol= "tcp"
  to_port= 22
  cidr_blocks = [var.my_ip] 

  }

 ingress {
  from_port= 8080
  protocol= "tcp"
  to_port= 8080
  cidr_blocks = ["0.0.0.0/0"] 

  }

  egress {
  from_port= 0
  protocol= "-1"
  to_port= 0
  cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

data "aws_ami" "my_latest_amazon_machine_image" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

output "aws_ami_id" {
    value = data.aws_ami.my_latest_amazon_machine_image.id
    }

resource "aws_key_pair" "my_ssh_key" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)
}
    
resource "aws_instance" "myapp_ec2" {
  ami= data.aws_ami.my_latest_amazon_machine_image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp_subnet_1.id
  vpc_security_group_ids = [aws_security_group.myapp_sg.id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.my_ssh_key.key_name

  tags = {
    Name = "${var.env_prefix}-ec2"
  }
}

output "ec2_public_ip" {
  value = aws_instance.myapp_ec2.public_ip
}
