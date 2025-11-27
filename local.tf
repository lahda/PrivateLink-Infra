locals {
  common_tags = {
    Terraform   = "true"
    Project     = var.project_name
    Environment = var.environment
  }

  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # User Data pour les serveurs API
  api_user_data = templatefile("${path.module}/scripts/api-server-userdata.sh", {
    log_group_name = aws_cloudwatch_log_group.api_logs.name
    region         = var.aws_region
  })

  # User Data pour l'instance Analytics
  analytics_user_data = templatefile("${path.module}/scripts/analytics-userdata.sh", {
    endpoint_dns = aws_vpc_endpoint.api.dns_entry[0].dns_name
  })
}