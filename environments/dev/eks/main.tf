# Data source to get the state of the VPC stack
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "iaac-dev-anil"
    key    = "terraform/services/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

module "eks" {
  source = "../../../modules/eks"

  cluster_name    = "dev-eks"
  cluster_version = "1.34"

  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  vpc_cidr           = data.terraform_remote_state.vpc.outputs.vpc_cidr_block

  instance_type = "t3.micro"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  environment = "dev"
  tenant      = "shared"
  project     = "eks"
  app         = "platform"
  team        = "devops"

  cluster_admin_role_arns = [
    "arn:aws:iam::303670280087:root",
    "arn:aws:iam::303670280087:role/githubactions_oidc_role"
  ]
}
