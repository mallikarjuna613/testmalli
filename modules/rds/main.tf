# rds-module/main.tf
variable "rds_configuration" {
  type = map(object({
    instance_class            = string
    engine                    = string
    engine_version            = string
    allocated_storage         = number
    storage_type              = string
    username                  = string
    password                  = string
    database_name             = string
    vpc_security_group_ids    = list(string)
    db_subnet_group_name      = string
    multi_az                  = bool
    backup_retention_period   = number
    storage_encrypted         = bool
    publicly_accessible       = bool
    tags                      = map(string)
  }))
}

resource "aws_db_instance" "rds_instance" {
  for_each                 = var.rds_configuration
  instance_class           = each.value.instance_class
  engine                   = each.value.engine
  engine_version           = each.value.engine_version
  allocated_storage        = each.value.allocated_storage
  storage_type             = each.value.storage_type
  username                 = each.value.username
  password                 = each.value.password
  db_name                  = each.value.database_name
  vpc_security_group_ids   = each.value.vpc_security_group_ids
  db_subnet_group_name     = each.value.db_subnet_group_name
  multi_az                 = each.value.multi_az
  backup_retention_period  = each.value.backup_retention_period
  storage_encrypted        = each.value.storage_encrypted
  publicly_accessible      = each.value.publicly_accessible

  tags = merge(each.value.tags, {
    "Name" = each.key
  })
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  for_each = var.rds_configuration

  name       = each.value.db_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = {
    Name = "rds-subnet-group-${each.key}"
  }
}
