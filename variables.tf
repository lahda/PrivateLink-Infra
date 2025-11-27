/*
variables.tf - variables for PrivateLink-Infra Terraform module
Adjust defaults and add/remove variables to match your project layout.
*/

variable "project_name" {
  description = "Logical project name used in tags and resource names."
  type        = string
  default     = "private-link-infra"
}

variable "environment" {
  description = "Deployment environment (used for names/tags)."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^([a-z0-9-]+)$", var.environment))
    error_message = "environment must consist of lowercase letters, numbers or hyphens."
  }
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Optional AWS CLI profile to use with the provider. Set to null to rely on environment/default chain."
  type        = string
  default     = null
}

variable "create_vpc" {
  description = "When true, module will create a new VPC. When false, supply vpc_id and subnet ids."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "Existing VPC id to use when create_vpc = false."
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC to create when create_vpc = true."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets when creating a VPC."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets when creating a VPC."
  type        = list(string)
  default     = ["10.0.16.0/20", "10.0.32.0/20"]
}

variable "subnet_ids" {
  description = "List of subnet ids to use for interface endpoints (required when not creating VPC)."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group ids to attach to interface endpoints."
  type        = list(string)
  default     = []
}

variable "enable_private_dns" {
  description = "Enable private DNS for interface endpoints (typical for AWS service endpoints)."
  type        = bool
  default     = true
}

variable "interface_endpoints" {
  description = <<EOT
Map of interface endpoints to create. Key is an identifier you choose.
Each value is an object:
{
    service_name         = string  # AWS service name or com.amazonaws.vpce.<svc>
    subnet_ids           = list(string) # subnets for the ENIs (optional if subnet_ids variable set)
    security_group_ids   = list(string) # SGs for the endpoint (optional if security_group_ids variable set)
    private_dns_enabled  = bool    # override enable_private_dns per endpoint
}
EOT
  type = map(object({
    service_name        = string
    subnet_ids          = optional(list(string), [])
    security_group_ids  = optional(list(string), [])
    private_dns_enabled = optional(bool, null)
  }))
  default = {}
}

variable "create_endpoint_service" {
  description = "When true, create a VPC Endpoint Service (for exposing an NLB-backed service)."
  type        = bool
  default     = false
}

variable "network_load_balancer_arn" {
  description = "ARN of the Network Load Balancer backing the endpoint service (required when create_endpoint_service = true)."
  type        = string
  default     = null
}

variable "endpoint_service_allowed_principals" {
  description = "List of AWS Principal ARNs (IAM roles/accounts) allowed to create interface endpoints to your service."
  type        = list(string)
  default     = []
}

variable "route_table_ids" {
  description = "Optional list of route table ids to associate with gateway endpoints (if any)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to apply to all created resources. Module will merge with required tags (project/environment)."
  type        = map(string)
  default     = {}
}

variable "allowed_cidrs" {
  description = "Optional list of CIDR blocks allowed for security groups created by the module."
  type        = list(string)
  default     = []
}

variable "log_level" {
  description = "Verbosity of any helper logging/resources (non-provider)."
  type        = string
  default     = "info"

  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "log_level must be one of: debug, info, warn, error."
  }
}

# Instance type for EC2 instances (API + Analytics)
variable "instance_type" {
  description = "EC2 instance type for API and analytics instances."
  type        = string
  default     = "t3.micro"
}

# CIDR for the provider VPC
variable "vpc_provider_cidr" {
  description = "CIDR block used for the provider VPC."
  type        = string
  default     = "10.0.0.0/16"
}

# Management IP (used for SSH rules). Default is open; override in terraform.tfvars for security.
variable "my_ip" {
  description = "CIDR block allowed for administrative access (SSH). Override this in terraform.tfvars for security."
  type        = string
  default     = "0.0.0.0/0"
}

# Whether endpoint service connections require manual acceptance
variable "endpoint_acceptance_required" {
  description = "When true, endpoint service connections require acceptance. When false, they are auto-accepted in same account."
  type        = bool
  default     = false
}

# Enable creation of VPC Flow Logs and related IAM role/policy
variable "enable_vpc_flow_logs" {
  description = "Enable creation of VPC Flow Logs resources."
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the Network Load Balancer."
  type        = bool
  default     = false
}

# CIDR for the consumer/analytics VPC
variable "vpc_consumer_cidr" {
  description = "CIDR block used for the consumer (analytics) VPC."
  type        = string
  default     = "10.1.0.0/16"
}