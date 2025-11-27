resource "aws_instance" "api_server" {
  count                  = 2
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.provider_private[count.index].id
  vpc_security_group_ids = [aws_security_group.provider_api.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = local.api_user_data

  root_block_device {
    volume_type = "gp3"
    # Increase size to satisfy AMI snapshot minimum (some AMIs require >=30GB)
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge(
    local.common_tags,
    {
      Name = "API-Server-IT-AZ${count.index + 1}"
      Role = "API-Backend"
      AZ   = local.azs[count.index]
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}