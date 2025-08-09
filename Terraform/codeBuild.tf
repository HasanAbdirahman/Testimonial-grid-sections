resource "aws_s3_bucket" "Terra-S3" {
  bucket = "code-build"
  acl    = "private"
}

resource "aws_iam_role" "Terra-Role" {
  name = "Code-Build-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "Terra-Policy" {
  role = aws_iam_role.Terra-Role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          aws_s3_bucket.Terra-S3.arn,
          "${aws_s3_bucket.Terra-S3.arn}/*"   # this line is fine as is
        ]
      }
    ]
  })
}

resource "aws_codebuild_project" "Terra-CodeBuild" {
  name          = "test-project"
  description   = "Single CodeBuild project"
  build_timeout = 5
  service_role  = aws_iam_role.Terra-Role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.Terra-S3.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.Terra-S3.bucket}/build-log"  # fixed from .id to .bucket
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/HasanAbdirahman/Testimonial-grid-sections.git"
    git_clone_depth = 1
    git_submodules_config {
      fetch_submodules = true
    }
    buildspec       = "my-buildspec.yml"  # ensure this file exists in your repo root
  }

  source_version = "main"

  vpc_config {
    vpc_id = aws_vpc.Terra-VPC.id
    subnets = aws_subnet.Terra-Public-Subnets[*].id  # fixed splat syntax
    security_group_ids = [aws_default_security_group.default.id]
  }

  tags = {
    Environment = "Test"
  }
}
