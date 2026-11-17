output "endpoint_dns_name" {
  description = "Regional DNS name of the PrivateLink interface endpoint (use it from the consumer VPC)."
  value       = aws_vpc_endpoint.api.dns_entry[0].dns_name
}

output "endpoint_state" {
  description = "State of the interface endpoint (must be 'available')."
  value       = aws_vpc_endpoint.api.state
}

output "nlb_target_group_arn" {
  description = "Target group ARN, to check target health."
  value       = aws_lb_target_group.api.arn
}

output "analytics_instance_public_ip" {
  description = "Public IP of the analytics client instance."
  value       = aws_instance.analytics_client.public_ip
}

output "test_command" {
  description = "Run this on the analytics instance to test the API through PrivateLink."
  value       = "curl -s http://${aws_vpc_endpoint.api.dns_entry[0].dns_name}/health"
}
