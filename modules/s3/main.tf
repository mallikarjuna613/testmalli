# s3-module/main.tf
variable "s3_configuration" {
  type = map(object({
    bucket_name          = string
    versioning_enabled   = bool
    logging_configuration = object({
      target_bucket = string
      target_prefix = string
    })
    lifecycle_rules = list(object({
      id      = string
      enabled = bool
      transitions = list(object({
        days          = number
        storage_class = string
      }))
      expiration = object({
        days = number
      })
    }))
    server_side_encryption = object({
      enabled = bool
      sse_algorithm = string
    })
    tags = map(string)
  }))
}

# Create S3 Buckets
resource "aws_s3_bucket" "this" {
  for_each = var.s3_configuration

  bucket = each.value.bucket_name

  tags = merge(each.value.tags, {
    "Name" = each.key
  })
}

# Enable Versioning
resource "aws_s3_bucket_versioning" "versioning" {
  for_each = var.s3_configuration

  bucket = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status = each.value.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# Enable Logging
resource "aws_s3_bucket_logging" "logging" {
  for_each = var.s3_configuration

  bucket        = aws_s3_bucket.this[each.key].id
  target_bucket = each.value.logging_configuration.target_bucket
  target_prefix = each.value.logging_configuration.target_prefix
}

# Add Lifecycle Rules
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  for_each = var.s3_configuration

  bucket = aws_s3_bucket.this[each.key].id

  dynamic "rule" {
    for_each = each.value.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      expiration {
        days = rule.value.expiration.days
      }
    }
  }
}

# Enable Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  for_each = var.s3_configuration

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = each.value.server_side_encryption.sse_algorithm
    }
  }
}
