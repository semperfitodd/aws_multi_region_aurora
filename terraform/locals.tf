locals {
  availability_zones_0 = [
    data.aws_availability_zones.region_0.names[0],
    data.aws_availability_zones.region_0.names[1],
    data.aws_availability_zones.region_0.names[2],
  ]

  public_subnets_0 = [
    cidrsubnet(local.vpc_cidr_0, 6, 0),
    cidrsubnet(local.vpc_cidr_0, 6, 1),
    cidrsubnet(local.vpc_cidr_0, 6, 2),
  ]

  private_subnets_0 = [
    cidrsubnet(local.vpc_cidr_0, 6, 4),
    cidrsubnet(local.vpc_cidr_0, 6, 5),
    cidrsubnet(local.vpc_cidr_0, 6, 6),
  ]

  database_subnets_0 = [
    cidrsubnet(local.vpc_cidr_0, 6, 7),
    cidrsubnet(local.vpc_cidr_0, 6, 8),
    cidrsubnet(local.vpc_cidr_0, 6, 9),
  ]

  availability_zones_1 = [
    data.aws_availability_zones.region_1.names[0],
    data.aws_availability_zones.region_1.names[1],
    data.aws_availability_zones.region_1.names[2],
  ]

  public_subnets_1 = [
    cidrsubnet(local.vpc_cidr_1, 6, 0),
    cidrsubnet(local.vpc_cidr_1, 6, 1),
    cidrsubnet(local.vpc_cidr_1, 6, 2),
  ]

  private_subnets_1 = [
    cidrsubnet(local.vpc_cidr_1, 6, 4),
    cidrsubnet(local.vpc_cidr_1, 6, 5),
    cidrsubnet(local.vpc_cidr_1, 6, 6),
  ]

  database_subnets_1 = [
    cidrsubnet(local.vpc_cidr_1, 6, 7),
    cidrsubnet(local.vpc_cidr_1, 6, 8),
    cidrsubnet(local.vpc_cidr_1, 6, 9),
  ]

  database_username = "aurora_admin"

  database_password = random_password.master.result

  region_0 = "us-east-2"

  region_1 = "eu-west-1"

  vpc_cidr_0 = "10.100.0.0/16"

  vpc_cidr_1 = "10.200.0.0/16"

  vpc_route_tables_0 = flatten([module.vpc_0.private_route_table_ids, module.vpc_0.public_route_table_ids])

  vpc_route_tables_1 = flatten([module.vpc_1.private_route_table_ids, module.vpc_1.public_route_table_ids])
}