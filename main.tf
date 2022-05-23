
##
## DATA
##

data "aws_caller_identity" "current" {}

##
## LOCALS
##
locals {
  source_dir        = "${path.module}/source"
  envvars           = jsondecode(var.envvars)
  context           = jsondecode(var.exo_context)
  service           = local.context.unit.name
  service_uid       = substr(local.context.unit.id, -5, -1)
  service_name_safe = join("-", split(" ", lower(replace(local.context.unit.name, "[^\\w\\d]|_", ""))))
  service_key       = "${local.service_name_safe}-${local.service_uid}"
}

resource "aws_codebuild_project" "main" {
  name           = local.service_key
  description    = "Exobase deployed task-runner for ${local.service}"
  build_timeout  = var.timeout
  queued_timeout = 5
  service_role   = aws_iam_role.main.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    dynamic "environment_variable" {
      for_each = local.envvars
      content {
        name  = environment_variable.value["name"]
        value = environment_variable.value["value"]
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = local.service
    }
  }

  source {
    type     = "S3"
    location = "${aws_s3_bucket.storage.bucket}/source.zip"
  }

}

//
// ARCHIVE STORAGE (S3)
//

resource "aws_s3_bucket" "storage" {
  bucket = local.service_key
}

resource "aws_s3_bucket_acl" "storage" {
  bucket = aws_s3_bucket.storage.id
  acl    = "private"
}

resource "aws_s3_object" "zip" {
  bucket = aws_s3_bucket.storage.bucket
  key    = "source.zip"
  source = "${path.module}/source.zip"
  etag   = filemd5("${path.module}/source.zip")
}

//
// IAM
//
resource "aws_iam_role" "main" {
  name               = local.service_key
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "main" {
  role   = aws_iam_role.main.name
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.storage.arn}",
        "${aws_s3_bucket.storage.arn}/*"
      ]
    }
  ]
}
POLICY
}

##
## BRIDGE API
##

module "bridge_api" {
  source = "exobase-inc/exo-ts-lambda-api/aws"
  version = "0.0.7"

  count = var.use_bridge ? 1 : 0

  exo_context = var.exo_context
  exo_source = "${path.module}/bridge"

  envvars = jsonencode([
    {
      name = "AWS_CODE_BUILD_PROJECT_NAME",
      value = aws_codebuild_project.main.name
    },
    {
      name = "BRIDGE_API_KEY",
      value = "our-little-secret"
    }
  ])
}

resource "aws_iam_policy" "policy" {
  count = var.use_bridge ? 1 : 0
  name        = "${aws_codebuild_project.main}-caller"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "codebuild:StartBuild"
      ],
      "Effect": "Allow",
      "Resource": "${aws_codebuild_project.main.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach" {
  count = var.use_bridge ? 1 : 0
  role       = module.bridge_api.role_arn
  policy_arn = aws_iam_policy.policy[0].arn
}