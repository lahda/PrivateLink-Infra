resource "aws_vpc_endpoint" "api" {
  vpc_id             = aws_vpc.consumer.id
  service_name       = aws_vpc_endpoint_service.api.service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.consumer_private.id]
  security_group_ids = [aws_security_group.consumer_endpoint.id]
  # The endpoint service does not provide a private DNS name, so disable private DNS.
  private_dns_enabled = false

  tags = merge(
    local.common_tags,
    {
      Name = "Endpoint-TechCorp-API"
    }
  )
}

# Auto-accept endpoint connection (same account)
resource "aws_vpc_endpoint_connection_accepter" "api" {
  count = var.endpoint_acceptance_required ? 0 : 1

  vpc_endpoint_service_id = aws_vpc_endpoint_service.api.id
  vpc_endpoint_id         = aws_vpc_endpoint.api.id
}