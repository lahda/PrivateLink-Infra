# CHANGELOG

All notable changes made to this Terraform project are recorded below.

## 2025-11-27 - Fixes and cleanup

- **Variables added**: `instance_type`, `vpc_provider_cidr`, `my_ip`, `endpoint_acceptance_required`, `enable_vpc_flow_logs`, `enable_deletion_protection`, `vpc_consumer_cidr` (in `variables.tf`). Added defaults to `terraform.tfvars` for quick testing.
- **Provider tags**: Removed dynamic `CreatedAt = timestamp()` from provider `default_tags` in `main.tf` to prevent "Provider produced inconsistent final plan" errors.
- **NLB health check**: Updated `NLB-Provider.tf` target group health check to use `protocol = "TCP"` and removed HTTP-only fields (NLB requires TCP health check for TCP targets).
- **User-data templates**: Replaced file reads with `templatefile` usage via `local.api_user_data` and `local.analytics_user_data`; added `scripts/api-server-userdata.sh` and `scripts/analytics-userdata.sh` (template-ready). Left a deprecated `scripts/analytic-userdata.sh` with a note.
- **VPC Endpoint**: Disabled `private_dns_enabled` for `aws_vpc_endpoint.api` because the endpoint service does not provide a private DNS name (prevents CreateVpcEndpoint 400 error).
- **EC2 root volumes**: Increased `root_block_device.volume_size` to `30` GB for `ec2-api-server` and analytics instance to satisfy AMI snapshot minimum size.
- **Security defaults**: Added `vpc_consumer_cidr` and populated security-group-related variables to avoid undefined variable errors.

## Notes / Recommendations

- Replace `my_ip` in `terraform.tfvars` with your secure management CIDR before applying (current default is wide-open for convenience/testing).
- Review `scripts/api-server-userdata.sh` — the Flask app runs as `root` on port 80; consider running under a service user and hardening for production.
- If you want a creation timestamp tag, prefer a static `variable "created_at"` set once in `terraform.tfvars` rather than `timestamp()` in provider tags.

## Commands to verify locally

```powershell
cd 'C:\Users\EAZYTraining\Documents\PrivateLink-Infra'
terraform fmt -recursive
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

If you want, I can create a Git commit with these changes. Suggested commit message:

```
fix(terraform): add missing variables, fix NLB health check, adjust user-data and root volumes
```
