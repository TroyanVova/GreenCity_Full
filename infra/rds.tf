resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = aws_subnet.public[*].id

  tags = {
    Name = "${var.project_name}-db-subnets"
  }
}

resource "aws_db_instance" "postgres" {
  identifier     = "${var.project_name}-db"
  engine         = "postgres"
  engine_version = "16"

  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false

  skip_final_snapshot = true
  backup_retention_period = 0

  tags = {
    Name = "${var.project_name}-db"
  }
}
