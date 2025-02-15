provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket   = "218961167216-infra"
    region   = "us-east-1"
    key      = "terraform/apps/analytics-module/dev/analytics/terraform.tfstate"
  }
}

locals {
  lambda_name  = "analytics_lambda_edge"
}

resource "aws_iam_role" "lambda_role" {

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": "Stmt1"
    }
  ]
}
EOF

}

resource "aws_cloudwatch_log_group" "terraform_lambda_edge_python_log_group" {
  # The name must match what the default log group is named for the lambda function
  # in order to have the retention value applied.
  name              = "/aws/lambda/us-east-1.analytics_lambda_edge"
  retention_in_days = 30
  tags = {
    Name        = "analytics_lambda_edge"
  }
}

resource "aws_iam_policy" "lambda_logging" {
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

data "archive_file" "viewer_response_lambda" {
  type        = "zip"
  source_file = "./lambda_code/index.mjs"
  output_path = "viewer_response_lambda.zip"
}

resource "aws_lambda_function" "viewer_response_lambda" {
  depends_on    = [aws_iam_role_policy_attachment.lambda_logs]
  filename      = data.archive_file.viewer_response_lambda.output_path
  function_name = local.lambda_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256(data.archive_file.viewer_response_lambda.output_path)

  runtime = "nodejs20.x"

  publish = true
  tags = {
    Name        = "analytics_lambda_edge"
  }
}
