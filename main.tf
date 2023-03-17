
resource "aws_ecs_task_definition" "database_migration" {
  family                   = "${local.cluster_name}-database-migration"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  task_role_arn            = data.aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "database-migration"
      image     = "database-migration:${var.app_version}"
      cpu       = 1
      memory    = 2048
      essential = true
      secrets = [
        {
          name      = "DATABASE_PASSWORD",
          valueFrom = "${data.aws_secretsmanager_secret.db_password.arn}"
        }
      ]
      environment = [
        {
          name  = "SCHEMA_MIGRATION_COMMAND"
          value = "${var.command_options} update"
        },
        {
          name  = "DATABASE_URL"
          value = "jdbc:oracle:thin:@${data.aws_db_instance.database.endpoint}:${tostring("${data.aws_db_instance.database.port}")}/${data.aws_db_instance.database.db_name}"
        },
        {
          name  = "DATABASE_USER"
          value = "${var.name}"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${local.project_name}"
          awslogs-region        = "${var.region}"
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "database-migration"
        }
      }

    }
  ])
}

resource "aws_ecs_task_definition" "database_rollback" {
  family                   = "${local.cluster_name}-database-rollback"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  task_role_arn            = data.aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "database-rollback"
      image     = "database-migration:${var.app_version}"
      cpu       = 1
      memory    = 2048
      essential = true
      secrets = [
        {
          name      = "DATABASE_PASSWORD",
          valueFrom = "${data.aws_secretsmanager_secret.db_password.arn}"
        }
      ]
      environment = [
        {
          name  = "SCHEMA_MIGRATION_COMMAND"
          value = "${var.command_options} rollback-count ${var.rollback_count}"
        },
        {
          name  = "DATABASE_URL"
          value = "jdbc:oracle:thin:@${data.aws_db_instance.database.endpoint}:${tostring("${data.aws_db_instance.database.port}")}/${data.aws_db_instance.database.db_name}"
        },
        {
          name  = "DATABASE_USER"
          value = "${var.name}"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${local.project_name}"
          awslogs-region        = "${var.region}"
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "database-migration"
        }
      }
    }
  ])
}

resource "aws_security_group" "database_migration" {
  name   = "${local.project_name}-sg-for-database-migration"
  vpc_id = data.aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
