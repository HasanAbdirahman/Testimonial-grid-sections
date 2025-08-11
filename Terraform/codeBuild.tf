resource "aws_s3_bucket" "Terra-S3" {
  bucket        = "my-unique-code-build-1234567890"
  force_destroy = true

}

resource "aws_s3_bucket_versioning" "Terra-S3-Versioning" {
  bucket = aws_s3_bucket.Terra-S3.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "Terra-Bucket-Ownership" {
  bucket = aws_s3_bucket.Terra-S3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "Terra-S3_ACL" {
  depends_on = [aws_s3_bucket_ownership_controls.Terra-Bucket-Ownership]

  bucket = aws_s3_bucket.Terra-S3.id
  acl    = "private"
}

resource "aws_iam_role" "Terra-Role" {
  name = "Code-Build-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
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
          "${aws_s3_bucket.Terra-S3.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = "arn:aws:codeconnections:us-east-1:619858587411:connection/9eb5f8fb-4190-4815-9364-b2ee44aed7bd"
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
    type      = "S3"
    location  = aws_s3_bucket.Terra-S3.bucket
    packaging = "NONE"
    name      = "build-output.zip"
    path      = "/"
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
      location = "${aws_s3_bucket.Terra-S3.bucket}/build-log"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/HasanAbdirahman/Testimonial-grid-sections.git"
    git_clone_depth = 1
    git_submodules_config {
      fetch_submodules = true
    }
    buildspec = "my-buildspec.yml"
  }


  # Add VPC config ONLY if your CodeBuild project *needs* access to resources inside your VPC.
  # Otherwise, comment this block out.
  # vpc_config {
  #   vpc_id             = aws_vpc.Terra-VPC.id
  #   subnets            = aws_subnet.Terra-Public-Subnets[*].id
  #   security_group_ids = [aws_default_security_group.default.id]
  # }

  tags = {
    Environment = "Test"
  }
}
