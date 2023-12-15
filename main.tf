locals {
  azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  private_subnets = { for az in local.azs : az => {
    name = "infra-prod-private-${az}"
    cidr = "10.0.${index(local.azs, az) + 1}.0/24"
  } }

  public_subnets = { for az in local.azs : az => {
    name = "infra-prod-public-${az}"
    cidr = "10.0.${index(local.azs, az) + 100}.0/24"
  } }
}

module "infra_prod_vpc" {
  source     = "./modules/vpc"
  name       = "infra-prod"
  cidr_block = "10.0.0.0/16"
}

module "infra_prod_private_subnets" {
  source            = "./modules/subnet"
  for_each          = local.private_subnets
  vpc_id            = module.infra_prod_vpc.id
  name              = each.value.name
  cidr              = each.value.cidr
  availability_zone = each.key
  public            = false
}

module "infra_prod_public_subnets" {
  source            = "./modules/subnet"
  for_each          = local.public_subnets
  vpc_id            = module.infra_prod_vpc.id
  name              = each.value.name
  cidr              = each.value.cidr
  availability_zone = each.key
  public            = true
}

module "infra_prod_igw" {
  source   = "./modules/internet_gateway"
  vpc_id   = module.infra_prod_vpc.id
  vpc_name = module.infra_prod_vpc.name
}

module "infra_prod_natgw" {
  source            = "./modules/nat_gateway"
  vpc_id            = module.infra_prod_vpc.id
  vpc_name          = module.infra_prod_vpc.name
  availability_zone = each.value

  for_each         = { for az in local.azs : az => az }
  public_subnet_id = module.infra_prod_public_subnets[each.value].id
}

module "infra_prod_public_route_table" {
  source     = "./modules/public_route_table"
  vpc_id     = module.infra_prod_vpc.id
  name       = "${module.infra_prod_vpc.name}-public-rt"
  routes     = [{ cidr_block = "0.0.0.0/0", gateway_id = module.infra_prod_igw.id }]
}

resource "aws_route_table_association" "infra_prod_public_rt_association" {
  for_each       = module.infra_prod_public_subnets
  route_table_id = module.infra_prod_public_route_table.id
  subnet_id      = each.value.id
}

module "infra_prod_private_route_table" {
  source       = "./modules/private_route_table"
  vpc_name     = module.infra_prod_vpc.name
  vpc_id       = module.infra_prod_vpc.id
  nat_gateways = { for az, ngw in module.infra_prod_natgw : az => ngw.id }
  subnets      = { for az, subnet in module.infra_prod_private_subnets : az => subnet.id }
}
