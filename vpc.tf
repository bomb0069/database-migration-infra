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

