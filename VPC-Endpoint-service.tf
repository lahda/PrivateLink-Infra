resource "aws_vpc_endpoint_service" "api" {
  acceptance_required        = var.endpoint_acceptance_required
  network_load_balancer_arns = [aws_lb.provider.arn]

  allowed_principals = var.endpoint_acceptance_required ? [] : [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "PrivateLink-TechCorp-API"
    }
  )
}