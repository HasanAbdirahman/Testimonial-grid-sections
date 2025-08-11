resource "aws_iam_role_policy" "Terra-CodePipelinePolicy" {
  role = aws_iam_role.Terra-CodePipelineRole.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*",
          "codebuild:*",
          "codedeploy:*",
          "codestar-connections:UseConnection",
          "iam:PassRole"
        ],
        Resource = [
          "*",                               # For s3, codebuild, codestar-connections
          aws_iam_role.Terra-DeployRole.arn  # For iam:PassRole specifically
        ]
      }
    ]
  })
}


resource "aws_codepipeline" "Terra-Pipeline" {
  name     = "html-css-deploy-pipeline"
  role_arn = aws_iam_role.Terra-CodePipelineRole.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.Terra-S3.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn = "arn:aws:codeconnections:us-east-1:619858587411:connection/9eb5f8fb-4190-4815-9364-b2ee44aed7bd"
        FullRepositoryId = "HasanAbdirahman/Testimonial-grid-sections"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.Terra-CodeBuild.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.Terra-DeployApp.name
        DeploymentGroupName = aws_codedeploy_deployment_group.Terra-Deployment-Group.deployment_group_name
      }
    }
  }
}
