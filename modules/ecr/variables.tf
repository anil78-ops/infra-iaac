variable "repositories" {
  description = "List of ECR repositories"
  type        = list(string)
}

variable "tags" {
  description = "Tags for repositories"
  type        = map(string)
  default     = {}
}