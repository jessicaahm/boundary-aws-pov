provider "aws" {
  region = var.region
}

# Create EC2 in AWS

# Data source to get the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


# Security Group for EC2
resource "aws_security_group" "ubuntu_sg" {
  name_prefix = "ubuntu-ec2-sg-"
  vpc_id      = var.vpc_id
  description = "Security group for Ubuntu EC2 instance"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "linux"
  }
}

# EC2 Instance
resource "aws_instance" "ubuntu_egress" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = "subnet-04e029f18d52a0ddd"
  vpc_security_group_ids = [aws_security_group.ubuntu_sg.id]
  key_name               = "boundary"

  tags = {
    Name = "Linux2-EC2-Egress-Instance"
  }
}

resource "aws_instance" "ubuntu_ingress" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = "subnet-0655ad674eb5c114c"
  vpc_security_group_ids = [aws_security_group.ubuntu_sg.id]
  key_name               = "boundary"

  tags = {
    Name = "Linux2-EC2-Ingress-Instance"
  }
}
# Output the instance details
# output "ubuntu_instance_id" {
#   value = aws_instance.ubuntu.id
# }

# output "ubuntu_private_ip" {
#   value = aws_instance.ubuntu.private_ip
# }
