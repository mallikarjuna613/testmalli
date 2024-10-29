module "my_lambdas" {
  source = "./lambda-module"

  lambda_configuration = {
    function1 = {
      aws_region          = "us-west-2"
      config_bucket       = "my-config-bucket"
      log_retention_in_days = 14
      runtime             = "nodejs14.x"
      handler             = "index.handler"
      timeout             = 10
      memory_size         = 128
      role_policies = [
        {
          action   = ["s3:GetObject", "s3:PutObject"]
          resource = ["arn:aws:s3:::my-config-bucket/*"]
          effect   = "Allow"
        },
        {
          action   = ["dynamodb:Query"]
          resource = ["arn:aws:dynamodb:us-west-2:123456789012:table/my-table"]
          effect   = "Allow"
        }
      ]
    }
    function2 = {
      aws_region          = "us-west-2"
      config_bucket       = "my-config-bucket"
      log_retention_in_days = 14
      runtime             = "python3.8"
      handler             = "lambda_function.lambda_handler"
      timeout             = 15
      memory_size         = 256
      role_policies = [
        {
          action   = ["sqs:SendMessage", "sqs:ReceiveMessage"]
          resource = ["arn:aws:sqs:us-west-2:123456789012:my-queue"]
          effect   = "Allow"
        }
      ]
    }
    # Add more functions here...
  }
}
