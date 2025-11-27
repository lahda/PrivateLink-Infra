# PrivateLink-Infra

Ce dépôt contient une configuration Terraform pour déployer une architecture PrivateLink simple (VPC provider + VPC consumer, NLB, EC2 instances, VPC Endpoint Service).

## Objectif
- Déployer une petite infrastructure AWS pour démontrer un service exposé via AWS PrivateLink (NLB + VPC Endpoint Service) et une instance client (analytics) qui consomme le service.

## Structure principale
- `*.tf` : fichiers Terraform (VPC, security groups, NLB, endpoint service, EC2, IAM, CloudWatch).
- `scripts/` : user-data pour les instances (`api-server-userdata.sh`, `analytics-userdata.sh`).
- `terraform.tfvars` : valeurs par défaut (ne pas committer de secrets).
- `CHANGELOG.md` : résumé des corrections récentes.

## Prérequis
- Terraform 1.0+ installé
- AWS CLI / credentials configurés (ou utilisez un `aws_profile` dans `terraform.tfvars`)

## Commandes rapides (PowerShell)
```powershell
cd 'C:\Users\EAZYTraining\Documents\PrivateLink-Infra'
terraform fmt -recursive
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
# Si tout est OK
terraform apply -var-file="terraform.tfvars"
```

## Points importants / Sécurité
- Remplacez `my_ip` dans `terraform.tfvars` par votre CIDR administratif (ex. `203.0.113.4/32`) avant d'appliquer en production. Par défaut il est `0.0.0.0/0` pour faciliter les tests.
- Les fichiers d'état Terraform (`terraform.tfstate`, `terraform.tfstate.backup`) et `terraform.tfvars` sont sensibles — ne les committez pas. `.gitignore` contient des patterns, mais si l'état a déjà été ajouté au repo il faut le retirer de l'index Git (`git rm --cached <file>`).
- Le script `scripts/api-server-userdata.sh` fournit un exemple Flask minimal exécuté en tant que `root` sur le port 80 : durcir pour production (utilisateur non-root, firewall, monitoring).

## Personnalisation
- `variables.tf` expose plusieurs options : instance types, CIDR pour VPC provider/consumer, activation des VPC Flow Logs, etc. Ajustez `terraform.tfvars` selon votre environnement.

## Aide / Prochaine étape
Si vous souhaitez que je :
- crée un commit Git avec les modifications, ou
- restaure une configuration de tags incluant un timestamp de création (via une variable `created_at`), ou
- améliore les user-data pour installer SSM/CloudWatch agents et exécuter le service sous un utilisateur non-root,
indiquez votre préférence et je m'en occupe.
