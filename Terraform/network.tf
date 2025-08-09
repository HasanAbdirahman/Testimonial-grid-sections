data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "Terra-VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "Terra-VPC"
    Environment = local.Environment
    Project     = local.Project
    Owner       = local.Owner
    Terraform   = local.Terraform
  }
}


resource "aws_subnet" "Terra-Public-Subnets" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.Terra-VPC.id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Terra-Public-Subnet-${count.index + 1}"
    Environment = local.Environment
    Project     = local.Project
    Owner       = local.Owner
    Terraform   = local.Terraform
  }
}

resource "aws_internet_gateway" "Terra-IGW" {
  vpc_id = aws_vpc.Terra-VPC.id

  tags = {
    Name = "Terra-IGW"
  }
}

resource "aws_route_table" "Terra-RT" {
  vpc_id = aws_vpc.Terra-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Terra-IGW.id
  }

  tags = {
    Name        = "Terra-RT"
    Environment = local.Environment
    Project     = local.Project
    Owner       = local.Owner
    Terraform   = local.Terraform
  }
}

resource "aws_route_table_association" "Terra-RTA" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.Terra-Public-Subnets[count.index].id
  route_table_id = aws_route_table.Terra-RT.id
}


resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.Terra-VPC.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
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
}
