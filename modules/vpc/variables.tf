variable "project_name" {
  description = "The name of the project, used for tagging resources."
  type        = string
}

variable "environment" {
  description = "The environment name, used for tagging resources."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnets" {
  description = "A list of CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of CIDR blocks for private subnets."
  type        = list(string)
}

variable "availability_zones" {
  description = "A list of availability zones to create subnets in."
  type        = list(string)
}
variable "tenant" {
  description = "The name of the tenant."
  type        = string
}

variable "project" {
  description = "The name of the project."
  type        = string
}

variable "app" {
  description = "The name of the application or service."
  type        = string
}

variable "team" {
  description = "The team responsible for the resource."
  type        = string
}

variable "zone" {
  description = "The zone where the component is hosted."
  type        = string
}
variable "eks_cluster_name" {
  description = "The name of the EKS cluster to associate the subnets with. If empty, no cluster-specific tags will be added."
  type        = string
  default     = ""
}