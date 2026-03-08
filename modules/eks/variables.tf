############################################################
# EKS Cluster Configuration
############################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

############################################################
# Networking Configuration
############################################################

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for worker nodes"
  type        = list(string)
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the Kubernetes API server"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the Kubernetes API server"
  type        = bool
  default     = false
}

############################################################
# Node Group Configuration
############################################################

variable "instance_type" {
  description = "EC2 instance type used for EKS worker nodes"
  type        = string
  default     = "t3.micro"
}

############################################################
# Tagging
############################################################

variable "environment" {
  description = "Environment tag (e.g., dev, staging, prod)"
  type        = string
}

variable "tenant" {
  description = "Tenant identifier"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "app" {
  description = "Application name"
  type        = string
}

variable "team" {
  description = "Team responsible for the cluster"
  type        = string
}

############################################################
# Access Control
############################################################

variable "cluster_admin_role_arns" {
  description = "List of IAM role ARNs that should have admin access to the cluster"
  type        = list(string)
  default     = []
}