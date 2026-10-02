#This Terraform configuration file creates a VPC with two public and two private subnets across two availability zones. 
#It also provisions two EC2 instances, one in each private subnet.

#VPC level Configuration
resource "aws_vpc" "lab" {
  cidr_block = "172.0.0.0/24"

  tags = {
    Name = "lab-vpc"
  }
}

#Subnet level Configuration
resource "aws_subnet" "priv_az1" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = "172.0.0.0/28"
  availability_zone = "us-east-2a"

  tags = {
    Name = "private subnet for AZ1"
  }
}

resource "aws_subnet" "pub_az1" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = "172.0.0.16/28"
  availability_zone = "us-east-2a"

  tags = {
    Name = "public subnet for AZ1"
  }
}

resource "aws_subnet" "priv_az2" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = "172.0.0.32/28"
  availability_zone = "us-east-2b"


  tags = {
    Name = "private subnet for AZ2-commit-"
  }
}

resource "aws_subnet" "pub_az2" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = "172.0.0.48/28"
  availability_zone = "us-east-2b"


  tags = {
    Name = "public subnet for AZ2-git-commit"
  }
}


