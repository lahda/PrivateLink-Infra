resource "aws_instance" "analytics_client" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.consumer_public.id
  vpc_security_group_ids = [aws_security_group.consumer_instance.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = local.analytics_user_data

  root_block_device {
    volume_type = "gp3"
    # Match the API server root volume size: some AMI snapshots require >=30GB
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
      Name = "Analytics-Client-Instance"
      Role = "Analytics"
    }
  )

  depends_on = [
    aws_vpc_endpoint.api
  ]
}