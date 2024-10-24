# creating DB subnet 
resource "aws_db_subnet_group" "database" {
  
  name       = "database-sbg"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "DB-subnet"
  }
}
# creating RDS
resource "aws_db_instance" "petclinic-db" {
  identifier             = var.db-identifier
  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [var.db-sg]
  allocated_storage      = 10
  db_name                = var.dbname
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = var.dbusername
  password               = var.dbpassword
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  publicly_accessible    = true
  storage_type           = "gp2"
}