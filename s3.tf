module "my_s3_buckets" {
  source = "./s3-module"

  s3_configuration = {
    bucket1 = {
      bucket_name          = "my-bucket-1"
      versioning_enabled   = true
      logging_configuration = {
        target_bucket = "log-bucket"
        target_prefix = "my-bucket-1-logs/"
      }
      lifecycle_rules = [
        {
          id        = "rule1"
          enabled   = true
          transitions = [
            {
              days          = 30
              storage_class = "GLACIER"
            }
          ]
          expiration = {
            days = 365
          }
        }
      ]
      server_side_encryption = {
        enabled      = true
        sse_algorithm = "AES256"
      }
      tags = {
        Environment = "dev"
        Department  = "data-team"
      }
    }

    bucket2 = {
      bucket_name          = "my-bucket-2"
      versioning_enabled   = false
      logging_configuration = {
        target_bucket = "log-bucket"
        target_prefix = "my-bucket-2-logs/"
      }
      lifecycle_rules = [
        {
          id        = "rule2"
          enabled   = true
          transitions = [
            {
              days          = 60
              storage_class = "STANDARD_IA"
            }
          ]
          expiration = {
            days = 730
          }
        }
      ]
      server_side_encryption = {
        enabled      = true
        sse_algorithm = "aws:kms"
      }
      tags = {
        Environment = "prod"
        Department  = "finance"
      }
    }
  }
}
