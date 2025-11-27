resource "aws_vpc" "consumer" {
  cidr_block           = var.vpc_consumer_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name       = "VPC-Analytics"
      Department = "Analytics"
      Type       = "Consumer"
    }
  )
}

# VPC Flow Logs Consumer
resource "aws_flow_log" "consumer" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  iam_role_arn    = aws_iam_role.vpc_flow_log_role[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs_consumer.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.consumer.id

  tags = merge(
    local.common_tags,
    {
      Name = "Consumer-VPC-FlowLog"
    }
  )
}

# Subnet Public Consumer
resource "aws_subnet" "consumer_public" {
  vpc_id                  = aws_vpc.consumer.id
  cidr_block              = cidrsubnet(var.vpc_consumer_cidr, 8, 0)
  availability_zone       = local.azs[0]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "Consumer-Public-Subnet"
      Tier = "Public"
    }
  )
}

# Subnet Private Consumer (pour VPC Endpoint)
resource "aws_subnet" "consumer_private" {
  vpc_id            = aws_vpc.consumer.id
  cidr_block        = cidrsubnet(var.vpc_consumer_cidr, 8, 1)
  availability_zone = local.azs[0]

  tags = merge(
    local.common_tags,
    {
      Name = "Consumer-Private-Subnet"
      Tier = "Private"
    }
  )
}

# Internet Gateway Consumer
resource "aws_internet_gateway" "consumer" {
  vpc_id = aws_vpc.consumer.id

  tags = merge(
    local.common_tags,
    {
      Name = "Consumer-IGW"
    }
  )
}

# Route Table Public Consumer
resource "aws_route_table" "consumer_public" {
  vpc_id = aws_vpc.consumer.id

  tags = merge(
    local.common_tags,
    {
      Name = "Consumer-Public-RT"
    }
  )
}

resource "aws_route" "consumer_public_internet" {
  route_table_id         = aws_route_table.consumer_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.consumer.id
}

resource "aws_route_table_association" "consumer_public" {
  subnet_id      = aws_subnet.consumer_public.id
  route_table_id = aws_route_table.consumer_public.id
}

# Route Table Private Consumer
resource "aws_route_table" "consumer_private" {
  vpc_id = aws_vpc.consumer.id

  tags = merge(
    local.common_tags,
    {
      Name = "Consumer-Private-RT"
    }
  )
}

resource "aws_route_table_association" "consumer_private" {
  subnet_id      = aws_subnet.consumer_private.id
  route_table_id = aws_route_table.consumer_private.id
}