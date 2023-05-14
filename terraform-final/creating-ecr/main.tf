
# Create an ECR repository
resource "aws_ecr_repository" "project-repo" {
  name = "project-repo" 

# Add a lifecycle policy to the repository to manage image expiration
  lifecycle_policy = jsonencode({
    rules = [
      {
        action {
          type = "expire"
          days = 30
        }
        selection {
          tag_status = "untagged"
          count_type = "sinceImagePushed"
          count_unit = "days"
          count_number = 30
        }
      }
    ]
  })
}

# Output the repository URL
output "repository_url" {
  value = aws_ecr_repository.my_project_repository.repository_url
}
