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

#########################################################################

module "my_rds" {
  source = "./rds-module"

  rds_configuration = {
    database1 = {
      instance_class           = "db.t3.medium"
      engine                   = "mysql"
      engine_version           = "8.0"
      allocated_storage        = 20
      storage_type             = "gp2"
      username                 = "admin"
      password                 = "securepassword"
      database_name            = "mydb"
      vpc_security_group_ids   = ["sg-123456"]
      db_subnet_group_name     = "rds-subnet-group-1"
      multi_az                 = false
      backup_retention_period  = 7
      storage_encrypted        = true
      publicly_accessible      = false
      tags = {
        Environment = "dev"
        Role        = "database-server"
      }
    },
    database2 = {
      instance_class           = "db.t3.large"
      engine                   = "postgres"
      engine_version           = "13"
      allocated_storage        = 50
      storage_type             = "gp3"
      username                 = "postgres"
      password                 = "anothersecurepassword"
      database_name            = "myotherdb"
      vpc_security_group_ids   = ["sg-654321"]
      db_subnet_group_name     = "rds-subnet-group-2"
      multi_az                 = true
      backup_retention_period  = 14
      storage_encrypted        = true
      publicly_accessible      = true
      tags = {
        Environment = "prod"
        Role        = "db-prod-server"
      }
    }
  }

  # Subnet IDs for the RDS Subnet Group
  subnet_ids = ["subnet-123456", "subnet-654321"]
}


######################################################################

module "my_vpc" {
  source = "./vpc-module"

  vpc_configuration = {
    vpc1 = {
      cidr_block            = "10.0.0.0/16"
      enable_dns_support    = true
      enable_dns_hostnames  = true
      public_subnets = [
        {
          cidr_block       = "10.0.1.0/24"
          availability_zone = "us-west-2a"
        },
        {
          cidr_block       = "10.0.2.0/24"
          availability_zone = "us-west-2b"
        }
      ]
      private_subnets = [
        {
          cidr_block       = "10.0.3.0/24"
          availability_zone = "us-west-2a"
        },
        {
          cidr_block       = "10.0.4.0/24"
          availability_zone = "us-west-2b"
        }
      ]
      security_groups = [
        {
          name = "web-sg"
          rules = [
            {
              protocol   = "tcp"
              from_port  = 80
              to_port    = 80
              cidr_block = "0.0.0.0/0"
            },
            {
              protocol   = "tcp"
              from_port  = 443
              to_port    = 443
              cidr_block = "0.0.0.0/0"
            }
          ]
        },
        {
          name = "ssh-sg"
          rules = [
            {
              protocol   = "tcp"
              from_port  = 22
              to_port    = 22
              cidr_block = "192.168.1.0/24"
            }
          ]
        }
      ]
      tags = {
        Environment = "dev"
        Department  = "engineering"
      }
    }
  }
}
