resource "aws_security_group" "consumer_endpoint" {
  name        = "SG-VPC-Endpoint-Analytics"
  description = "Security group for VPC Endpoint Interface"
  vpc_id      = aws_vpc.consumer.id

  tags = merge(
    local.common_tags,
    {
      Name = "SG-VPC-Endpoint-Analytics"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "consumer_endpoint_http" {
  security_group_id = aws_security_group.consumer_endpoint.id
  description       = "HTTP from Analytics VPC"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_consumer_cidr
}

resource "aws_vpc_security_group_ingress_rule" "consumer_endpoint_https" {
  security_group_id = aws_security_group.consumer_endpoint.id
  description       = "HTTPS from Analytics VPC"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_consumer_cidr
}

resource "aws_vpc_security_group_egress_rule" "consumer_endpoint_all" {
  security_group_id = aws_security_group.consumer_endpoint.id
  description       = "Allow all outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "consumer_instance" {
  name        = "SG-Analytics-Client"
  description = "Security group for Analytics client instance"
  vpc_id      = aws_vpc.consumer.id

  tags = merge(
    local.common_tags,
    {
      Name = "SG-Analytics-Client"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "consumer_instance_ssh" {
  security_group_id = aws_security_group.consumer_instance.id
  description       = "SSH from my IP"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.my_ip
}

resource "aws_vpc_security_group_egress_rule" "consumer_instance_all" {
  security_group_id = aws_security_group.consumer_instance.id
  description       = "Allow all outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
