# creating DB subnet 
resource "aws_db_subnet_group" "database" {
  name       = "${var.name}-rds-sub"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name}-rds-sub"
  }
}
# creating RDS
resource "aws_db_instance" "petclinic-db" {
  identifier             = var.db-identifier
  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  allocated_storage      = 10
  db_name                = var.dbname
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = var.dbusername
  password               = var.dbpassword
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  multi_az               = false
  publicly_accessible    = true
  storage_type           = "gp2"
}
# RDS security group
resource "aws_security_group" "rds-sg" {
  name        = "${var.name}-rds-sg"
  description = "Allow outbound traffic"
  vpc_id      = var.vpc-id
  ingress {
    description     = "MYSQPORT"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"] 
  }
  egress {
    description = "All TRAFFIC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.name}-rds-sg"
  }
}
