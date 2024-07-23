provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "First-VPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "First-VPC"
  }
}

resource "aws_internet_gateway" "Public-gateway" {
  vpc_id = aws_vpc.First-VPC.id
  tags = {
    Name = "Public-gateway"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.First-VPC.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.First-VPC.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "private-subnet"
  }
}

resource "aws_route_table" "public-routetable" {
  vpc_id = aws_vpc.First-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Public-gateway.id
  }
  tags = {
    Name = "public-routetable"
  }
}

resource "aws_route_table_association" "public-subnet-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-routetable.id
}

resource "aws_route_table" "private-routetable" {
  vpc_id = aws_vpc.First-VPC.id
  tags = {
    Name = "private-routetable"
  }
}

resource "aws_route_table_association" "private-subnet-association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-routetable.id
}

resource "aws_network_acl" "private-NACL" {
  vpc_id = aws_vpc.First-VPC.id
  tags = {
    Name = "private-NACL"
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_network_acl" "public-NACL" {
  vpc_id = aws_vpc.First-VPC.id
  tags = {
    Name = "public-NACL"
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_network_acl_association" "private-subnet-association" {
  subnet_id = aws_subnet.private-subnet.id
  network_acl_id = aws_network_acl.private-NACL.id
}

resource "aws_network_acl_association" "public-subnet-association" {
  subnet_id = aws_subnet.public-subnet.id
  network_acl_id = aws_network_acl.public-NACL.id
}

resource "aws_instance" "public-instance" {
  ami           = "ami-0c55b159cbfafe1f0" # Update this with a valid AMI ID for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet.id

  user_data = <<-EOF
    #!/bin/bash
    #use this for your user data
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>A hot bowl of VPC a la carte</h1> /var/www/html/index.html
  EOF

  tags = {
    Name = "public-instance"
  }
}

resource "aws_instance" "private-instance" {
  ami           = "ami-0c55b159cbfafe1f0" # Update this with a valid AMI ID for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private-subnet.id

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello from private instance" > /var/www/html/index.html
    nohup busybox httpd -f -p 80 &
  EOF

  tags = {
    Name = "private-instance"
  }
}

