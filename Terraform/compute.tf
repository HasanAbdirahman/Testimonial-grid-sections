data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}



# IAM Role for EC2
resource "aws_iam_role" "ec2_codedeploy_role" {
  name = "EC2CodeDeployRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach AWS Managed Policies
resource "aws_iam_role_policy_attachment" "codedeploy_ec2_attach" {
  role       = aws_iam_role.ec2_codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role_policy_attachment" "s3_read_attach" {
  role       = aws_iam_role.ec2_codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Instance profile for EC2
resource "aws_iam_instance_profile" "ec2_codedeploy_profile" {
  name = "EC2CodeDeployInstanceProfileV2"
  role = aws_iam_role.ec2_codedeploy_role.name
}


# Example EC2 instance (add iam_instance_profile)
resource "aws_instance" "codedeploy_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "dev-sec-ops"

  iam_instance_profile = aws_iam_instance_profile.ec2_codedeploy_profile.name

  tags = {
    Name        = "EC2-CODE-DEPLOY"
    Env = "Production"
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install ruby -y
    apt-get install wget -y

    # Download and install the CodeDeploy agent
    cd /home/ubuntu
    wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
    chmod +x ./install
    ./install auto

    # Start the agent
    systemctl start codedeploy-agent
    systemctl enable codedeploy-agent
  EOF
}
