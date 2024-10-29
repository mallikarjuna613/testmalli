# vpc-module/main.tf
variable "vpc_configuration" {
  type = map(object({
    cidr_block            = string
    enable_dns_support    = bool
    enable_dns_hostnames  = bool
    public_subnets        = list(object({
      cidr_block = string
      availability_zone = string
    }))
    private_subnets       = list(object({
      cidr_block = string
      availability_zone = string
    }))
    security_groups = list(object({
      name   = string
      rules  = list(object({
        protocol   = string
        from_port  = number
        to_port    = number
        cidr_block = string
      }))
    }))
    tags = map(string)
  }))
}

# Create VPC
resource "aws_vpc" "this" {
  for_each             = var.vpc_configuration
  cidr_block           = each.value.cidr_block
  enable_dns_support   = each.value.enable_dns_support
  enable_dns_hostnames = each.value.enable_dns_hostnames

  tags = merge(each.value.tags, {
    "Name" = each.key
  })
}

# Create Public Subnets
resource "aws_subnet" "public_subnet" {
  for_each = {
    for k, v in var.vpc_configuration : k => v.public_subnets
  }

  count            = length(each.value)
  vpc_id           = aws_vpc.this[each.key].id
  cidr_block       = each.value[count.index].cidr_block
  availability_zone = each.value[count.index].availability_zone

  map_public_ip_on_launch = true

  tags = {
    Name = "${each.key}-public-subnet-${count.index}"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnet" {
  for_each = {
    for k, v in var.vpc_configuration : k => v.private_subnets
  }

  count            = length(each.value)
  vpc_id           = aws_vpc.this[each.key].id
  cidr_block       = each.value[count.index].cidr_block
  availability_zone = each.value[count.index].availability_zone

  tags = {
    Name = "${each.key}-private-subnet-${count.index}"
  }
}

# Create Security Groups
resource "aws_security_group" "sg" {
  for_each = var.vpc_configuration

  count   = length(each.value.security_groups)
  vpc_id  = aws_vpc.this[each.key].id
  name    = each.value.security_groups[count.index].name
  tags    = {
    Name = "${each.key}-sg-${count.index}"
  }

  # Create security group rules
  dynamic "ingress" {
    for_each = each.value.security_groups[count.index].rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = [ingress.value.cidr_block]
    }
  }

  dynamic "egress" {
    for_each = each.value.security_groups[count.index].rules
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
