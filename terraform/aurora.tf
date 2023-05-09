resource "aws_rds_global_cluster" "this" {
  global_cluster_identifier = local.environment
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.02.3"
  storage_encrypted         = true
}

module "aurora_primary" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name                      = local.environment
  database_name             = aws_rds_global_cluster.this.database_name
  engine                    = aws_rds_global_cluster.this.engine
  engine_version            = aws_rds_global_cluster.this.engine_version
  global_cluster_identifier = aws_rds_global_cluster.this.id
  instance_class            = "db.r6g.large"
  instances                 = { for i in range(1) : i => {} }

  kms_key_id = data.aws_kms_key.rds_0.arn

  vpc_id               = module.vpc_0.vpc_id
  db_subnet_group_name = module.vpc_0.database_subnet_group_name
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = concat(
        module.vpc_0.private_subnets_cidr_blocks,
        module.vpc_1.private_subnets_cidr_blocks,
      )
    }
  }

  master_username = local.database_username
  master_password = local.database_password

  skip_final_snapshot = true

  tags = var.tags
}

module "aurora_secondary" {
  source = "terraform-aws-modules/rds-aurora/aws"

  providers = { aws = aws.eu-west-1 }

  is_primary_cluster = false

  name                      = local.environment
  engine                    = aws_rds_global_cluster.this.engine
  engine_version            = aws_rds_global_cluster.this.engine_version
  global_cluster_identifier = aws_rds_global_cluster.this.id
  source_region             = local.region_0
  instance_class            = "db.r6g.large"
  instances                 = { for i in range(1) : i => {} }

  kms_key_id = data.aws_kms_key.rds_1.arn

  vpc_id               = module.vpc_1.vpc_id
  db_subnet_group_name = module.vpc_1.database_subnet_group_name
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = concat(
        module.vpc_0.private_subnets_cidr_blocks,
        module.vpc_1.private_subnets_cidr_blocks,
      )
    }
  }

  skip_final_snapshot = true

  depends_on = [
    module.aurora_primary
  ]

  tags = var.tags
}

resource "random_password" "master" {
  length  = 20
  special = false
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name                    = "${local.environment}-aurora-credentials"
  description             = "${local.environment} aurora username and password"
  recovery_window_in_days = "7"

  depends_on = [module.aurora_primary]
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode(
    {
      username = module.aurora_primary.cluster_master_username
      password = module.aurora_primary.cluster_master_password
    }
  )

  depends_on = [module.aurora_primary]
}