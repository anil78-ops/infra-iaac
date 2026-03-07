terraform {
  backend "s3" {
    bucket  = "iaac-dev"
    key     = "terraform/services/vpc/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    use_lockfile = true
  }
}