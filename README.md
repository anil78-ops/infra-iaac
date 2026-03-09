# Terraform Infrastructure as Code (IaC)

This repository contains **Terraform Infrastructure as Code (IaC)** used to provision and manage AWS infrastructure using reusable modules and automated CI/CD pipelines.

Infrastructure changes are automatically validated, planned, and applied using **GitHub Actions**.

---

# Repository Structure

```
infra-iaac
│
├── .github
│   └── workflows
│       └── iaac-terraform-dev.yml   # Terraform CI/CD workflow
│
├── environments
│   └── dev
│       ├── vpc
│       ├── eks
│       └── ecr
│
├── modules
│   ├── vpc
│   ├── eks
│   └── ecr
│
├── .gitignore
└── README.md
```

---

# Architecture Overview

This project follows a **modular Terraform architecture**.

### Modules Layer

Reusable infrastructure modules:

* **VPC** – Networking infrastructure
* **EKS** – Kubernetes cluster
* **ECR** – Container registry

These modules are reusable across environments.

---

### Environment Layer

Environment-specific infrastructure definitions.

Example:

```
environments/dev
```

Each environment calls the shared modules and provides environment-specific configuration.

Future environments may include:

```
environments/staging
environments/prod
```

---

# Infrastructure Components

## VPC

Creates the base networking infrastructure:

* VPC
* Public subnets
* Private subnets
* Internet Gateway
* NAT Gateway
* Route tables

---

## EKS

Creates an **Amazon EKS cluster** including:

* EKS control plane
* Managed node groups
* IAM roles
* Security groups
* Kubernetes networking

---

## ECR

Creates **Amazon Elastic Container Registry (ECR)** repositories used to store Docker images deployed to EKS.

---

# CI/CD Pipeline (GitHub Actions)

Terraform deployments are automated using **GitHub Actions**.

Workflow file:

```
.github/workflows/terraform-environments-dev.yml
```

The pipeline automatically detects which Terraform environment folders changed and runs Terraform only for those components.

Example folders monitored:

```
environments/dev/vpc
environments/dev/eks
environments/dev/ecr
```

---

# Pipeline Triggers

The workflow runs in three scenarios.

## 1. Pull Request (Plan)

When a PR modifies files under:

```
environments/dev/**
```

The pipeline runs:

* `terraform fmt`
* `terraform validate`
* `terraform plan`

The Terraform plan is automatically **posted as a comment on the pull request**.

This allows reviewers to verify infrastructure changes before merging.

---

## 2. Push to Main (Apply)

When changes are merged into `main`, the pipeline:

1. Detects modified dev modules
2. Runs Terraform apply automatically

Example:

```
PR → Review → Merge → Auto Deploy
```

Only the changed infrastructure folders are applied.

---

## 3. Manual Destroy (Workflow Dispatch)

Infrastructure can be manually destroyed using the GitHub Actions UI.

Workflow input:

```
env: <module-name>
```

Example:

```
env = vpc
env = eks
env = ecr
```

This runs:

```
terraform destroy
```

For the selected module.

---

# Change Detection

The pipeline automatically detects which infrastructure modules changed.

Example commit:

```
environments/dev/vpc/main.tf
```

Only the **vpc** module will run Terraform.

This significantly reduces pipeline runtime.

---

# AWS Authentication (OIDC)

The pipeline uses **GitHub OIDC authentication** to assume an AWS IAM role.

No AWS credentials are stored in the repository.

Required GitHub Secrets:

```
AWS_dev_OIDC_ARN
AWS_dev_REGION
```

Authentication flow:

```
GitHub Actions
      ↓
OIDC Token
      ↓
AWS IAM Role Assume
      ↓
Temporary Credentials
```

This is the recommended **secure DevOps practice**.

---

# Terraform Workflow

Typical local workflow for engineers:

### Initialize

```
terraform init
```

### Validate

```
terraform validate
```

### Plan

```
terraform plan
```

### Apply

```
terraform apply
```

---

# Destroy Infrastructure

To destroy infrastructure using GitHub Actions:

1. Go to **Actions**
2. Select the workflow
3. Click **Run workflow**
4. Provide environment name

Example:

```
env: vpc
```

This will run:

```
terraform destroy
```

---

# Prerequisites

Required tools:

* Terraform >= 1.9
* AWS CLI
* Git

Verify installations:

```
terraform -v
aws --version
```

---

# Security Best Practices

This repository follows modern DevOps security practices.

* AWS authentication via **OIDC**
* No static AWS credentials
* Terraform state encrypted
* Infrastructure managed via pull requests
* Infrastructure changes reviewed before deployment

---

# DevOps Best Practices Implemented

✔ Infrastructure as Code
✔ Modular Terraform architecture
✔ Environment separation
✔ Automated CI/CD pipelines
✔ Secure AWS authentication (OIDC)
✔ PR-based infrastructure changes
✔ Automatic Terraform plan comments

---

# Maintainers

DevOps / Platform Engineering Team

---

# License

Internal infrastructure automation project.
