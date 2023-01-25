resource "aws_vpc" "aws_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "aws_subnet_a" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
//  map_public_ip_on_launch = true
}

resource "aws_subnet" "aws_subnet_b" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
//  map_public_ip_on_launch = true
}

 resource "aws_internet_gateway" "aws_internet_gateway" {
  vpc_id = aws_vpc.aws_vpc.id
}


resource "aws_security_group" "aws_security_group" {
  name        = "aws_security_group"
  description = "Example security group"
  vpc_id      = aws_vpc.aws_vpc.id
  
  ingress {
    from_port   = 0
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
