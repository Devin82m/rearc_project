# Rearc Skill Assesment
# Devin St. Clair 2021-10-23

###
# Networking Tasks
###

provider "aws" {
  region = "us-west-2a"
}

# Create a VPC
resource "aws_vpc" "prod_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hotsnames = true
  tags = {
    Environment = "Prod"
  }
}

# Create a Public Subnet
resource "aws_subnet" "prod_public" {
  vpc_id = aws_vpc.prod_vpc.id
  cidr_block            = "10.0.3.0/24"
  availability_zone       = "us-west-2a"
  tags = {
    Environment = "Prod"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.prod_vpc.id
  tags = {
    Environment = "Prod"
  }
}

# Create a Routing Table and associate it to the Subnet
resource "aws_route_table" "prod_vpc_us_west_2a_public" {
    vpc_id = aws_vpc.prod_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.prod_vpc_igw.id
    }

    tags = {
        Environment = "Prod"
    }
}

resource "aws_route_table_association" "prod_vpc_us_west_2a_public" {
    subnet_id = aws_subnet.prod_public.id
    route_table_id = aws_route_table.prod_vpc_us_west_2a_public.id
}

# Create a Security Group
resource "aws_security_group" "rearc_test_sg" {
  name        = "rearc_test_sg"
  description = "Allow SSH and TLS from anywhere, and 3000 from VPC "
  vpc_id = aws_vpc.prod_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 443
    to_port     = 433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24"]
  } 
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Environment = "Prod"
  }
}


###
# EC2 Instance Tasks
###

# Create EC2 Instance
resource "aws_instance" "rearc-devintest-ec2" {
  ami           = "ami-013a129d325529d4d"
  instance_type = "t2.micro"
  key_name = "Devin Test"
  vpc_security_group_ids = [ aws_security_group.rearc_test_sg.id ]
  subnet_id = aws_subnet.prod_public.id
  associate_public_ip_address = true
  user_data = << EOF
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
        sudo docker build . -t devin82m/rearc_test
        sudo docker run -p 3000:3000 -d devin82m/rearc_test       
	EOF  
  tags = {
    Name = "Devin Rearc Skill Assessment"
  }
}


###
# Load Balancer Taks
###

# Create Target Group


# Create Application Load Balancer
#resource "aws_lb" "rearc_devintest_alb" {
 #name               = "Rearc Devin Test ALB"
 # internal           = false
  #load_balancer_type = "application"
  #security_groups    = [aws_security_group.web.id]
  #subnets            = aws_subnet.public.*.id
  #enable_http2       = false
  #enable_deletion_protection = false
  #tags = {
  #  Environment = "Prod"
  #}
#}

###
# Optional SNS Notification Of Completion 
##

