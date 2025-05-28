terraform {
  backend "s3" {
    bucket         = "fm-my-unique-terraform-bucket-2025"
    key            = "CD/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/example-cluster"
  retention_in_days = 7

  tags = {
    Name        = "ECS Log Group"
    Environment = "dev"
  }
}

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}