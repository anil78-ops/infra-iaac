output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "A list of IDs for the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "A list of IDs for the private subnets."
  value       = module.vpc.private_subnet_ids
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = module.vpc.vpc_cidr_block
}

output "public_route_table_id" {
  description = "The ID of the public route table."
  value       = module.vpc.public_route_table_id
}

output "private_route_table_ids" {
  description = "A list of IDs for the private route tables."
  value       = module.vpc.private_route_table_ids
}
