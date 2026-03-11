# 🚀 Terraform Infrastructure as Code (IaC)

This repository contains **Terraform Infrastructure as Code (IaC)** used to provision and manage **AWS infrastructure** using a **modular Terraform architecture** and automated **GitHub Actions pipelines**.

Infrastructure changes are **validated, planned, and deployed automatically through CI/CD pipelines**.

---

# 📦 Repository Structure

```
infra-iaac
│
├── .github
│   └── workflows
│       └── iaac-terraform-dev.yml
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

# 🏗️ Architecture

This repository follows a **modular infrastructure architecture**.

```
Modules  →  Environments  →  CI/CD Deployment
```

Terraform modules are reusable and are called by environment-specific configurations.

---

# 📚 Modules

Reusable Terraform modules:

| Module | Description               |
| ------ | ------------------------- |
| 🌐 VPC | Networking infrastructure |
| ☸️ EKS | Kubernetes cluster        |
| 📦 ECR | Container image registry  |

---

# 🌍 Environments

Infrastructure is organized by environment.

Example:

```
environments/dev
```

Future environments may include:

```
environments/staging
environments/prod
```

Each environment calls reusable Terraform modules.

---

# ☁️ Infrastructure Components

## 🌐 VPC

Creates networking infrastructure:

* VPC
* Public Subnets
* Private Subnets
* Internet Gateway
* NAT Gateway
* Route Tables

---

## ☸️ EKS

Creates **Amazon Elastic Kubernetes Service (EKS)** cluster including:

* EKS Control Plane
* Managed Node Groups
* IAM Roles
* Security Groups

---

## 📦 ECR

Creates **Amazon Elastic Container Registry (ECR)** repositories for container images used by applications deployed to Kubernetes.

---

# 🌐 Kubernetes Application Routing (ALB Ingress)

Applications deployed to the **EKS cluster** are exposed using **AWS Application Load Balancer (ALB) Ingress Controller**.

The ingress routes external traffic to different microservices based on URL paths.

Example Kubernetes Ingress configuration:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: healthcare-ingress
  namespace: dev
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip

spec:
  rules:
  - http:
      paths:
      - path: /patients
        pathType: Prefix
        backend:
          service:
            name: patient-service
            port:
              number: 80

      - path: /appointments
        pathType: Prefix
        backend:
          service:
            name: appointment-service
            port:
              number: 80

      - path: /orders
        pathType: Prefix
        backend:
          service:
            name: order-service
            port:
              number: 80
```

### 🔀 Traffic Routing

| Path            | Service             |
| --------------- | ------------------- |
| `/patients`     | patient-service     |
| `/appointments` | appointment-service |
| `/orders`       | order-service       |

### 🌍 Load Balancer

The **AWS ALB Ingress Controller** automatically:

* Creates an **Application Load Balancer**
* Configures **target groups**
* Routes traffic to **Kubernetes services**

---

# ⚙️ CI/CD Pipeline

Infrastructure deployments are automated using **GitHub Actions**.

Workflow file:

```
.github/workflows/iaac-terraform-dev.yml
```

The pipeline automatically detects changed Terraform modules and runs Terraform only for those components.

Example monitored folders:

```
environments/dev/vpc
environments/dev/eks
environments/dev/ecr
```

---

# 🔄 Pipeline Workflow

## 🟡 Pull Request (Terraform Plan)

When a Pull Request modifies:

```
environments/dev/**
```

The pipeline runs:

```
terraform fmt
terraform validate
terraform plan
```

The **Terraform plan is automatically posted as a comment on the Pull Request**.

Example workflow:

```
DevOps-Person → Pull Request → Terraform Plan → Review
```

---

## 🟢 Push to Main (Terraform Apply)

When a Pull Request is merged into **main**:

```
PR → Merge → Terraform Apply
```

The pipeline:

* Detects changed modules
* Runs `terraform apply`
* Deploys infrastructure automatically

Only **modified modules are applied**.

---

## 🔴 Manual Destroy

Infrastructure can be destroyed manually using **GitHub Actions Workflow Dispatch**.

Required input:

```
env = <module-name>
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

---

# 🔍 Change Detection

The pipeline automatically detects which modules changed.

Example commit:

```
environments/dev/vpc/main.tf
```

Result:

```
Terraform runs only for VPC
```

This keeps **CI/CD pipelines fast and efficient**.

---

# 🔐 AWS Authentication (OIDC)

The pipeline uses **GitHub OIDC authentication** to access AWS.

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
AWS IAM Role
      ↓
Temporary Credentials
```

This is the **recommended AWS security best practice**.

---

# 🛠 Terraform Local Workflow

DevOps can run Terraform locally.

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

# 📋 Prerequisites

Required tools:

* Terraform >= 1.9
* AWS CLI
* Git

Verify installation:

```
terraform -v
aws --version
```

---

# 🔒 Security Best Practices

This repository follows modern **DevOps security standards**:

✔ AWS authentication via OIDC
✔ No static AWS credentials
✔ Infrastructure changes via Pull Requests
✔ Automated Terraform validation
✔ Controlled infrastructure deployments

---

# 🧠 DevOps Best Practices Implemented

✔ Infrastructure as Code
✔ Modular Terraform architecture
✔ Environment separation
✔ Automated CI/CD pipelines
✔ Secure AWS authentication
✔ PR-based infrastructure changes

---

# 👨‍💻 Maintainers

DevOps / Platform Engineering Team

---

# 📜 License

Internal infrastructure automation project.

---
