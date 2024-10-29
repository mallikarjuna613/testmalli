variable "lambda_configuration" {
  description = "Map of Lambda function configurations"
  type = map(object({
    aws_region          = string
    config_bucket       = string
    log_retention_in_days = number
    runtime             = string
    handler             = string
    timeout             = number
    memory_size         = number
    role_policies       = list(object({
      action   = list(string)
      resource = list(string)
      effect   = string
    }))
  }))
}

# IAM Role for Lambda Function
resource "aws_iam_role" "lambda_execution_role" {
  for_each = var.lambda_configuration

  name               = "${each.key}_lambda_execution_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# IAM Policy specific to each Lambda function
resource "aws_iam_policy" "lambda_policy" {
  for_each = var.lambda_configuration

  name        = "${each.key}_lambda_policy"
  description = "Policy for ${each.key} Lambda function"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for p in each.value.role_policies : {
        Action   = p.action
        Resource = p.resource
        Effect   = p.effect
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
        Effect   = "Allow"
      }
    ]
  })
}

# Lambda Function resource
resource "aws_lambda_function" "this" {
  for_each = var.lambda_configuration

  function_name = each.key
  role          = aws_iam_role.lambda_execution_role[each.key].arn
  handler       = each.value.handler
  runtime       = each.value.runtime
  timeout       = each.value.timeout
  memory_size   = each.value.memory_size

  environment {
    variables = {
      CONFIG_BUCKET = each.value.config_bucket
    }
  }

  tags = {
    Name = each.key
  }
}

# CloudWatch Log Group for Lambda function
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  for_each = var.lambda_configuration

  name              = "/aws/lambda/${each.key}"
  retention_in_days = each.value.log_retention_in_days
}

# Attach the custom policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  for_each = var.lambda_configuration

  role       = aws_iam_role.lambda_execution_role[each.key].name
  policy_arn = aws_iam_policy.lambda_policy[each.key].arn
}

