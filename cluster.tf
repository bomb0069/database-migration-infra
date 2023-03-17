
provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "terraform-bucket"
    key    = "tfstate.tf"
    region = var.region
  }
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole-${local.project_name}"
}
