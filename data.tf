
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

locals {
  cluster_name = "${var.environment}-${var.name}"
  project_name = "${var.environment}-${var.name}"
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_subnets" "database" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    subnet-type = "database"
  }
}

data "aws_subnet" "database" {
  for_each = toset(data.aws_subnets.database.ids)
  id       = each.value
}


data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole-${local.project_name}"
}

data "aws_db_instance" "database" {
  db_instance_identifier = "rds${var.name}${var.environment}"
}

data "aws_secretsmanager_secret" "db_password" {
  name = "${local.cluster_name}-rds-password"
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}
