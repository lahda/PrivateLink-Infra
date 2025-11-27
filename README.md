# PrivateLink-Infra

This repository contains Terraform configuration to deploy a small AWS PrivateLink demo environment (provider VPC + consumer VPC, Network Load Balancer, EC2 instances, VPC Endpoint Service).

## Purpose
- Deploy a minimal AWS architecture that demonstrates exposing a service using AWS PrivateLink (NLB backed service + VPC Endpoint Service) and a client instance in a consumer VPC that calls the service.

## Repository layout
- `*.tf`: Terraform configuration files (VPCs, security groups, NLB, endpoint service, EC2, IAM, CloudWatch).
- `scripts/`: user-data scripts for instances (`api-server-userdata.sh`, `analytics-userdata.sh`).
- `terraform.tfvars`: environment-specific variable values (do not commit secrets).
- `CHANGELOG.md`: recent fixes and notes.

## Prerequisites
- Terraform 1.0 or newer installed
- AWS credentials configured (environment, shared `~/.aws/credentials`, or set `aws_profile` in `terraform.tfvars`)

## Quick start (PowerShell)
```powershell
cd 'C:\Users\EAZYTraining\Documents\PrivateLink-Infra'
terraform fmt -recursive
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
# If the plan looks good:
terraform apply -var-file="terraform.tfvars"
```

## Security notes
- `my_ip` in `terraform.tfvars` defaults to `0.0.0.0/0` for convenience during testing — change this to a restricted management CIDR (for example `203.0.113.4/32`) before applying in production.
- Terraform state files (`terraform.tfstate`, `terraform.tfstate.backup`) and `terraform.tfvars` may contain sensitive data and should not be committed. `.gitignore` already includes common patterns; if state files were previously committed, remove them from the Git index with `git rm --cached <file>` and commit.
- The example API user-data (`scripts/api-server-userdata.sh`) runs a simple Flask app as `root` on port 80. For production, run services under a non-root user and harden the instance (firewall rules, monitoring, regular package updates).

## Customization
- `variables.tf` exposes options such as instance types, provider/consumer VPC CIDRs, and toggles for VPC Flow Logs and endpoint acceptance. Update `terraform.tfvars` to match your environment.


