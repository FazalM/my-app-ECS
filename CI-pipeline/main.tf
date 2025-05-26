terraform {
  backend "s3" {
    bucket         = "fm-my-unique-terraform-bucket-2025"
    key            = "CI/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

resource "aws_ecr_repository" "my_ecr_app_repo" {
  name                 = "my-ecr-app-repo"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
