# ec2-module/main.tf
variable "ec2_configuration" {
  type = map(object({
    instance_type        = string
    ami_id               = string
    key_name             = string
    vpc_id               = string
    subnet_id            = string
    security_group_ids   = list(string)
    associate_public_ip  = bool
    root_block_device = object({
      volume_size = number
      volume_type = string
    })
    tags = map(string)
  }))
}

resource "aws_instance" "ec2_instance" {
  for_each              = var.ec2_configuration
  instance_type         = each.value.instance_type
  ami                   = each.value.ami_id
  key_name              = each.value.key_name
  vpc_security_group_ids = each.value.security_group_ids
  subnet_id             = each.value.subnet_id
  associate_public_ip_address = each.value.associate_public_ip

  root_block_device {
    volume_size = each.value.root_block_device.volume_size
    volume_type = each.value.root_block_device.volume_type
  }

  tags = merge(each.value.tags, {
    "Name" = each.key
  })
}

# Optional: Elastic IP
resource "aws_eip" "ec2_eip" {
  for_each      = var.ec2_configuration
  instance      = aws_instance.ec2_instance[each.key].id
  vpc           = true
  associate_with_private_ip = each.value.associate_public_ip ? aws_instance.ec2_instance[each.key].private_ip : null
}
