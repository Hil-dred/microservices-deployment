resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-demo-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "aurora-demo-subnet-group"
  }

  lifecycle {
    prevent_destroy = false  # Ensures the resource can be destroyed
  }
}



resource "aws_security_group" "aurora_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow access within your VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aurora-security-group"
  }
}



# resource "aws_rds_cluster" "microservices-demo" {
#   cluster_identifier = "microservices-demo"
#   engine             = "aurora-mysql"
#   engine_mode        = "provisioned"  # Change to "serverless" if using Serverless Aurora
#   engine_version     = "8.0.mysql_aurora.3.07.0" # Adjust as needed
#   database_name      = "test"
#   manage_master_user_password = true
#   master_username    = "demouser"
#   storage_encrypted  = true

#   serverlessv2_scaling_configuration {
#     max_capacity = 1.0
#     min_capacity = 0.5
#   }

#   vpc_security_group_ids  = [aws_security_group.aurora_sg.id]
#   db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
# }

# resource "aws_rds_cluster_instance" "microservices-demo-instance" {
#   cluster_identifier = aws_rds_cluster.microservices-demo.id
#   instance_class     = "db.serverless"
#   engine             = aws_rds_cluster.microservices-demo.engine
#   engine_version     = aws_rds_cluster.microservices-demo.engine_version
#   publicly_accessible = false  # Ensure this is false to keep it within private subnets
#   db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
# }


resource "aws_rds_cluster" "microservices-demo" {
  cluster_identifier = "microservices-demo"
  engine             = "aurora-mysql"
  engine_mode        = "provisioned"  # Change to "serverless" if using Serverless Aurora
  engine_version     = "8.0.mysql_aurora.3.07.0" # Adjust as needed
  database_name      = "test"
  manage_master_user_password = true
  master_username    = "demouser"
  storage_encrypted  = true

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }

  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name

  # Enable automated backups for point-in-time recovery
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
}

# Primary Writer Instance
resource "aws_rds_cluster_instance" "microservices-demo-instance" {
  cluster_identifier     = aws_rds_cluster.microservices-demo.id
  instance_class         = "db.serverless"
  engine                 = aws_rds_cluster.microservices-demo.engine
  engine_version         = aws_rds_cluster.microservices-demo.engine_version
  publicly_accessible    = false  # Ensure this is false to keep it within private subnets
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name
  availability_zone      = "us-east-2a"  # Example AZ, ensure correct AZ
}

# Reader Instance (Replica) for Data Replication
resource "aws_rds_cluster_instance" "microservices-demo-replica" {
  cluster_identifier     = aws_rds_cluster.microservices-demo.id
  instance_class         = "db.serverless"
  engine                 = aws_rds_cluster.microservices-demo.engine
  engine_version         = aws_rds_cluster.microservices-demo.engine_version
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name
  availability_zone      = "us-east-2b"  # Another AZ for high availability
  # Set this instance to a reader
  promotion_tier         = 1  # Lower tier for failover priority
}
