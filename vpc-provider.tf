resource "aws_vpc" "provider" {
  cidr_block           = var.vpc_provider_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name       = "VPC-IT-Production"
      Department = "IT"
      Type       = "Provider"
    }
  )
}

# VPC Flow Logs Provider
resource "aws_flow_log" "provider" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  iam_role_arn    = aws_iam_role.vpc_flow_log_role[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs_provider.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.provider.id

  tags = merge(
    local.common_tags,
    {
      Name = "Provider-VPC-FlowLog"
    }
  )
}

# Subnets Privés Provider
resource "aws_subnet" "provider_private" {
  count             = 2
  vpc_id            = aws_vpc.provider.id
  cidr_block        = cidrsubnet(var.vpc_provider_cidr, 8, count.index + 1)
  availability_zone = local.azs[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "Provider-Private-Subnet-AZ${count.index + 1}"
      Tier = "Private"
      AZ   = local.azs[count.index]
    }
  )
}

# Route Table Provider
resource "aws_route_table" "provider_private" {
  vpc_id = aws_vpc.provider.id

  tags = merge(
    local.common_tags,
    {
      Name = "Provider-Private-RT"
      Type = "Private"
    }
  )
}

resource "aws_route_table_association" "provider_private" {
  count          = 2
  subnet_id      = aws_subnet.provider_private[count.index].id
  route_table_id = aws_route_table.provider_private.id
}
