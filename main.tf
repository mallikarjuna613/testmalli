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


######################################################################################

module "my_ec2" {
  source = "./ec2-module"
  
  ec2_configuration = {
    instance1 = {
      instance_type        = "t2.micro"
      ami_id               = "ami-123456"
      key_name             = "my-key"
      vpc_id               = "vpc-123456"
      subnet_id            = "subnet-123456"
      security_group_ids   = ["sg-123456"]
      associate_public_ip  = true
      root_block_device = {
        volume_size = 30
        volume_type = "gp2"
      }
      tags = {
        Environment = "dev"
        Role        = "web-server"
      }
    },
    instance2 = {
      instance_type        = "t2.small"
      ami_id               = "ami-654321"
      key_name             = "my-key"
      vpc_id               = "vpc-654321"
      subnet_id            = "subnet-654321"
      security_group_ids   = ["sg-654321"]
      associate_public_ip  = false
      root_block_device = {
        volume_size = 50
        volume_type = "gp3"
      }
      tags = {
        Environment = "prod"
        Role        = "database"
      }
    }
  }
}
