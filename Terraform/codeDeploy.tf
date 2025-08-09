data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "Terra-DeployRole" {
  name               = "CodeDeploy-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.Terra-DeployRole.name
}

resource "aws_codedeploy_app" "Terra-DeployApp" {
  name = "Deploy-app"
}

resource "aws_sns_topic" "Terra-CodeDeploy-SNS" {
  name = "CodeDeploy-SNS-Topic"
}

resource "aws_codedeploy_deployment_group" "Terra-Deployment-Group" {
  app_name              = aws_codedeploy_app.Terra-DeployApp.name
  deployment_group_name = "deployment-group-1"
  service_role_arn      = aws_iam_role.Terra-DeployRole.arn

ec2_tag_set {
  ec2_tag_filter {
    key   = "Env"
    type  = "KEY_AND_VALUE"
    value = "Production"
  }

  ec2_tag_filter {
    key   = "Name"
    type  = "KEY_AND_VALUE"
    value = "EC2-CODE-DEPLOY"
  }
}


  trigger_configuration {
    trigger_events     = ["DeploymentFailure"]
    trigger_name       = "example-trigger"
    trigger_target_arn = aws_sns_topic.Terra-CodeDeploy-SNS.arn
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

 alarm_configuration {
  alarms  = [aws_cloudwatch_metric_alarm.foobar.alarm_name]
  enabled = true
}


  outdated_instances_strategy = "UPDATE"

  depends_on = [
    aws_instance.web,
    aws_cloudwatch_metric_alarm.foobar
  ]

}