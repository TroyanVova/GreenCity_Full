locals {
  ecr_repos = ["frontend", "backcore", "backuser"]
}

resource "aws_ecr_repository" "app" {
  for_each             = toset(local.ecr_repos)
  name                 = "${var.project_name}-${each.value}"  # має збігатись з Jenkinsfile.cloud/k8s-маніфестами (project-service, дефіс)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-${each.value}"
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  for_each   = aws_ecr_repository.app
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 3 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 3
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep only the last 10 tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "latest", "main"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = { type = "expire" }
      }
    ]
  })
}
