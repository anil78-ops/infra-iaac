terraform {
  backend "s3" {
    bucket  = "iaac-dev-anil"
    key     = "terraform/services/ecr/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}