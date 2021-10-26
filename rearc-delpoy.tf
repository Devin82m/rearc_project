# Rearc Skill Assesment
# Devin St. Clair 2021-10-23

###
# Networking Tasks
###

provider "aws" {
  region = "us-west-2"
}

# Create a VPC
resource "aws_vpc" "devintest_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# Create a Public Subnet A
resource "aws_subnet" "devintest_public_a" {
  vpc_id = aws_vpc.devintest_vpc.id
  cidr_block            = "10.0.3.0/24"
  availability_zone       = "us-west-2a"
  tags = {
    Name = "Public A"
  }
}

# Create a Public Subnet B
resource "aws_subnet" "devintest_public_b" {
  vpc_id = aws_vpc.devintest_vpc.id
  cidr_block            = "10.0.4.0/24"
  availability_zone       = "us-west-2b"
  tags = {
    Name = "Public B"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "devintest_igw" {
  vpc_id = aws_vpc.devintest_vpc.id
}

# Create a Routing Table and associate it to the Subnet
resource "aws_route_table" "devintest_vpc_public" {
    vpc_id = aws_vpc.devintest_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.devintest_igw.id
    }
}

resource "aws_route_table_association" "devintest_rt_a" {
    subnet_id = aws_subnet.devintest_public_a.id
    route_table_id = aws_route_table.devintest_vpc_public.id
}

resource "aws_route_table_association" "devintest_rt_b" {
    subnet_id = aws_subnet.devintest_public_b.id
    route_table_id = aws_route_table.devintest_vpc_public.id
}

# Create a Security Group
resource "aws_security_group" "devintest_sg" {
  name        = "devintest_sg"
  description = "Allow SSH and TLS from anywhere, and 3000 from VPC "
  vpc_id = aws_vpc.devintest_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.4.0/24"]
  } 
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


###
# EC2 Instance Tasks
###

# Create Key-Pair
resource "tls_private_key" "devin-test-kp" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"
  key_name   = "devintest-kp"
  public_key = tls_private_key.devin-test-kp.public_key_openssh
}

# Create EC2 Instance
resource "aws_instance" "devintest-ec2" {
  ami           = "ami-013a129d325529d4d"
  instance_type = "t2.micro"
  key_name = "devintest-kp"
  vpc_security_group_ids = [ aws_security_group.devintest_sg.id ]
  subnet_id = aws_subnet.devintest_public_a.id
  associate_public_ip_address = true
  user_data = <<-EOF
		#! /bin/bash
        sudo yum update -y
        sudo yum upgrade -y
        sudo yum install git -y
        cd /home/ec2-user/
        sudo git clone https://github.com/Devin82m/rearc_project.git
        cd /home/ec2-user/rearc_project
        sudo yum install docker -y
        sudo systemctl enable docker.service
        sudo systemctl start docker.service
        sudo docker build . -t devin82m/devintest
        sudo docker run -p 3000:3000 -d devin82m/devintest       
        EOF
}


###
# Load Balancer Tasks
###

# Import SSL Certificate
resource "aws_acm_certificate" "devintest_cert" {
  private_key = "${file("ca.key")}"
  certificate_body = "${file("ca.pem")}"
  }

# Create Target Group
resource "aws_lb_target_group" "devintest-tg" {
  name     = "devintest-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.devintest_vpc.id
}

# Attach Instance to TG
resource "aws_lb_target_group_attachment" "devintest-tg" {
  target_group_arn = aws_lb_target_group.devintest-tg.arn
  target_id        = aws_instance.devintest-ec2.id
  port             = 3000
}

 # Create Application Load Balancer
  resource "aws_lb" "devintest_alb" {
  name               = "devintest-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.devintest_sg.id]
  subnets            = [ aws_subnet.devintest_public_a.id,
  aws_subnet.devintest_public_b.id
  ]
  enable_http2       = false # I turned HTTP2 off because I still don't fully understand it see a need for it
  enable_deletion_protection = false
}

# Create ALB Listener
resource "aws_lb_listener" "devintest_listener" {
  load_balancer_arn = aws_lb.devintest_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate.devintest_cert.arn}"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.devintest-tg.arn
  }
}


###
# Optional SNS Notification Of Completion 
##
# This was overkill for this project and I was just going to email the output below.

# Output ALB DNS
output "alb_dns" {
  value       = aws_lb.devintest_alb.dns_name
  description = "The public DNS of the ALB."
}
