resource "aws_ecr_repository" "repo" {
  for_each = toset(var.repositories)

  name = each.value

  tags = var.tags
}