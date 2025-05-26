output "repository_uri" {
  value = aws_ecr_repository.my_ecr_app_repo.repository_url
  description = "The URI of the ECR repository"
}
