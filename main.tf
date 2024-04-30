provider "aws" {
  region = "your_region"
}

# Define VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Define public and private subnets in two availability zones
resource "aws_subnet" "public_subnet_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "your_az1"
}

resource "aws_subnet" "private_subnet_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "your_az1"
}

resource "aws_subnet" "public_subnet_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "your_az2"
}

resource "aws_subnet" "private_subnet_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "your_az2"
}

# EC2 Instances
resource "aws_instance" "ec2_instance1" {
  count         = 1
  ami           = "your_ami_id"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_az1.id
  tags = {
    Name = var.instance1_name
  }
}

resource "aws_instance" "ec2_instance2" {
  count         = 1
  ami           = "your_ami_id"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_az2.id
  tags = {
    Name = var.instance2_name
  }
}

# RDS instance
resource "aws_db_instance" "example" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "admin"
  password             = "your_password"
  subnet_group_name    = "mydb-subnet-group"
  vpc_security_group_ids = [aws_security_group.web_servers.id]

  tags = {
    Name = "mydb"
  }
}

# Security Groups
resource "aws_security_group" "web_servers" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_instance" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_servers.id]
  }
}

# Outputs
output "ec2_instance1_public_ip" {
  value = aws_instance.ec2_instance1.*.public_ip
}

output "ec2_instance2_public_ip" {
  value = aws_instance.ec2_instance2.*.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.example.endpoint
}
