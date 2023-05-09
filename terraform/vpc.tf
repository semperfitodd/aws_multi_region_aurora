module "vpc_0" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.14.2"

  azs                                             = local.availability_zones_0
  cidr                                            = local.vpc_cidr_0
  create_database_subnet_group                    = true
  create_flow_log_cloudwatch_iam_role             = true
  create_flow_log_cloudwatch_log_group            = true
  database_subnets                                = local.database_subnets_0
  enable_dhcp_options                             = true
  enable_dns_hostnames                            = true
  enable_dns_support                              = true
  enable_flow_log                                 = true
  enable_ipv6                                     = true
  enable_nat_gateway                              = true
  flow_log_cloudwatch_log_group_retention_in_days = 7
  flow_log_max_aggregation_interval               = 60
  name                                            = local.environment
  one_nat_gateway_per_az                          = false
  private_subnet_suffix                           = "private"
  private_subnets                                 = local.private_subnets_0
  public_subnets                                  = local.public_subnets_0
  single_nat_gateway                              = true
  tags                                            = var.tags
}

module "vpc_1" {
  providers = { aws = aws.eu-west-1 }
  source    = "terraform-aws-modules/vpc/aws"
  version   = "~> 3.14.2"

  azs                                             = local.availability_zones_1
  cidr                                            = local.vpc_cidr_1
  create_database_subnet_group                    = true
  create_flow_log_cloudwatch_iam_role             = true
  create_flow_log_cloudwatch_log_group            = true
  database_subnets                                = local.database_subnets_1
  enable_dhcp_options                             = true
  enable_dns_hostnames                            = true
  enable_dns_support                              = true
  enable_flow_log                                 = true
  enable_ipv6                                     = true
  enable_nat_gateway                              = true
  flow_log_cloudwatch_log_group_retention_in_days = 7
  flow_log_max_aggregation_interval               = 60
  name                                            = local.environment
  one_nat_gateway_per_az                          = false
  private_subnet_suffix                           = "private"
  private_subnets                                 = local.private_subnets_1
  public_subnets                                  = local.public_subnets_1
  single_nat_gateway                              = true
  tags                                            = var.tags
}

module "vpc_endpoints_0" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 3.14.2"

  vpc_id = module.vpc_0.vpc_id
  tags   = var.tags

  endpoints = {
    s3 = {
      route_table_ids = local.vpc_route_tables_0
      service         = "s3"
      service_type    = "Gateway"
      tags            = { Name = "s3-vpc-endpoint" }
    }
  }
}

module "vpc_endpoints_1" {
  providers = { aws = aws.eu-west-1 }
  source    = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version   = "~> 3.14.2"

  vpc_id = module.vpc_1.vpc_id
  tags   = var.tags

  endpoints = {
    s3 = {
      route_table_ids = local.vpc_route_tables_1
      service         = "s3"
      service_type    = "Gateway"
      tags            = { Name = "s3-vpc-endpoint" }
    }
  }
}

resource "aws_route" "peer_0" {
  count = length(local.vpc_route_tables_0)

  route_table_id            = local.vpc_route_tables_0[count.index]
  destination_cidr_block    = local.vpc_cidr_1
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

  depends_on = [aws_vpc_peering_connection.peer]
}

resource "aws_route" "peer_1" {
  provider = aws.eu-west-1
  count    = length(local.vpc_route_tables_1)

  route_table_id            = local.vpc_route_tables_1[count.index]
  destination_cidr_block    = local.vpc_cidr_0
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

  depends_on = [aws_vpc_peering_connection.peer]
}

resource "aws_vpc_peering_connection" "peer" {
  vpc_id = module.vpc_0.vpc_id

  peer_vpc_id = module.vpc_1.vpc_id
  peer_region = local.region_1

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = merge(var.tags, { Name = var.environment })
}

resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  provider = aws.eu-west-1

  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  tags = merge(var.tags, { Name = var.environment })
}