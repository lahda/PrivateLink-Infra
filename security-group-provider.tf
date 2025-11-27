resource "aws_security_group" "provider_api" {
  name        = "SG-API-Servers-IT"
  description = "Security group for API backend servers"
  vpc_id      = aws_vpc.provider.id

  tags = merge(
    local.common_tags,
    {
      Name = "SG-API-Servers-IT"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "provider_api_http" {
  security_group_id = aws_security_group.provider_api.id
  description       = "HTTP from VPC"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_provider_cidr
}

resource "aws_vpc_security_group_ingress_rule" "provider_api_ssh" {
  security_group_id = aws_security_group.provider_api.id
  description       = "SSH for management"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.my_ip
}

resource "aws_vpc_security_group_egress_rule" "provider_api_all" {
  security_group_id = aws_security_group.provider_api.id
  description       = "Allow all outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
