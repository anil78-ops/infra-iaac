module "ecr" {
  source = "../../../modules/ecr"

  repositories = [
    "orders",
    "patients",
    "appointments"
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "demo"
  }
}