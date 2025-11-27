resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/ec2/techcorp-api"
  retention_in_days = 7

  tags = merge(
    local.common_tags,
    {
      Name = "TechCorp-API-Logs"
    }
  )
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs_provider" {
  name              = "/aws/vpc/flowlogs/provider"
  retention_in_days = 7

  tags = merge(
    local.common_tags,
    {
      Name = "VPC-Provider-FlowLogs"
    }
  )
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs_consumer" {
  name              = "/aws/vpc/flowlogs/consumer"
  retention_in_days = 7

  tags = merge(
    local.common_tags,
    {
      Name = "VPC-Consumer-FlowLogs"
    }
  )
}