module "vpc" {
  source = "../../modules/vpc"

  project_name       = "my-iaac-vpc"
  environment        = "dev"
  vpc_cidr           = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
  tenant             = "internal"
  project            = "infra"
  app                = "infra-vpc-networking"
  team               = "devops"
  zone               = "public"
  eks_cluster_name   = "dev-eks"
}