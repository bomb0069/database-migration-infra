data "aws_db_instance" "database" {
  db_instance_identifier = "rds${var.name}${var.environment}"
}
