provider "aws" {
  region = var.aws_region
}

resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "IMMUTABLE" # impede sobrescrever uma tag já publicada (ex: reusar "latest")

  image_scanning_configuration {
    scan_on_push = true # escaneia a imagem por vulnerabilidades conhecidas toda vez que você faz push
  }

  tags = {
    Project   = "ai-incident-response"
    ManagedBy = "terraform"
  }
}

# Política de lifecycle: evita acumular imagens antigas pra sempre (economiza custo de storage)
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Mantém só as últimas 10 imagens"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}