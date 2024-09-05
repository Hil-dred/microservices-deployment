resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "aurora-subnet-group"
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
}

resource "aws_rds_cluster_instance" "microservices-demo-instance" {
  cluster_identifier = aws_rds_cluster.microservices-demo.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.microservices-demo.engine
  engine_version     = aws_rds_cluster.microservices-demo.engine_version
  publicly_accessible = false  # Ensure this is false to keep it within private subnets
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
}


