# IAM Role for EC2 instance to allow CodeDeploy access
resource "aws_iam_role" "ec2_codedeploy_role" {
  name = "EC2CodeDeployRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Custom IAM policy for CodeDeploy EC2 permissions
resource "aws_iam_policy" "codedeploy_ec2_policy" {
  name        = "CodeDeployEC2Policy"
  description = "Policy for EC2 instances to work with CodeDeploy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codedeploy:*",
          "s3:Get*",
          "s3:List*",
          "ec2:Describe*",
          "tag:GetTags",
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach custom policy to the EC2 role
resource "aws_iam_role_policy_attachment" "ec2_codedeploy_policy" {
  role       = aws_iam_role.ec2_codedeploy_role.name
  policy_arn = aws_iam_policy.codedeploy_ec2_policy.arn
}

# Create IAM instance profile for the EC2 role
resource "aws_iam_instance_profile" "ec2_codedeploy_profile" {
  name = "EC2CodeDeployInstanceProfile"
  role = aws_iam_role.ec2_codedeploy_role.name
}

# Data source to get latest Ubuntu AMI
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

# EC2 instance with CodeDeploy agent installation
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_codedeploy_profile.name

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2 ruby wget
    systemctl start apache2
    systemctl enable apache2

    cd /tmp
    wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
    chmod +x ./install
    ./install auto > /tmp/install.log 2>&1

    systemctl start codedeploy-agent
    systemctl enable codedeploy-agent
  EOF

  tags = {
    Name = "EC2-CODE-DEPLOY"
    Env  = "Production"
  }
}
