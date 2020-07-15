+provider "aws" {
  region = "ap-south-1"
  profile = "Moiz"
}

resource "aws_vpc" "myvpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "mypvc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "subnet-1"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     =  aws_vpc.myvpc.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "subnet-2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "mygateway"
  }
  depends_on = [aws_vpc.myvpc]
}


resource "aws_route_table" "rtable" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "myroute"
  }
}

resource "aws_route_table_association" "route_associate" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rtable.id
}

resource "aws_security_group" "webserver_sg" {
  name        = "allow_http_web1"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

    ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_ssh"
  }
  depends_on = [aws_vpc.myvpc]
}

resource "aws_security_group" "database_sg" {
  name        = "allow_all"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.myvpc.id


   ingress {
    description = "mysql allow"
    security_groups = [aws_security_group.webserver_sg.id]
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_mysql"
  }
  depends_on = [aws_vpc.myvpc]
}

resource "aws_security_group" "allow_bastion_sg" {
  name        = "allow_http_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "SSH from webserver"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_basiton_ssh"
  }
  depends_on = [aws_vpc.myvpc]
}

resource "aws_security_group" "bastion_sg" {
  name        = "allow_http"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "SSH from webserver"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_basiton_mysql"
  }
  depends_on = [aws_vpc.myvpc]
}

//ami-000cbce3e1b899ebd
resource "aws_instance" "wordpress" {
  ami           = "ami-005c362a40a9e9bd8"
  instance_type = "t2.micro"
  key_name = "key53"
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]

  tags = {
    Name = "webserver"
  }
}
// ami-49fa8e5f
resource "aws_instance" "mysql" {
  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  key_name = "key53"
  subnet_id = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.database_sg.id, aws_security_group.allow_bastion_sg.id]

  tags = {
    Name = "database"
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  key_name = "key53"
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion"
  }
}

resource "aws_eip" "myeip" {
	vpc = true
  // instance = aws_instance.mysql.id
  // associate_with_private_ip = "10.0.0.12"
  depends_on = [aws_internet_gateway.gw]
}


resource "aws_nat_gateway" "natting" {
	allocation_id = aws_eip.myeip.id
	subnet_id = aws_subnet.public_subnet.id

	tags = {
	Name = "mysql nat12"
	}
}

resource "aws_route_table" "nat_rtable" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natting.id
  }

  tags = {
    Name = "mynatroute"
  }
}


resource "aws_route_table_association" "route_associate2" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.nat_rtable.id
}

// resource "aws_route_table_association" "nat_mysql" {
// 	subnet_id = aws_subnet.private_subnet.id
// 	route_table_id = aws_route_table.nat_rtable.id
// }




















