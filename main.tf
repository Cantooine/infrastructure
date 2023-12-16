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
  source = "./modules/public_route_table"
  vpc_id = module.infra_prod_vpc.id
  name   = "${module.infra_prod_vpc.name}-public-rt"
  routes = [{ cidr_block = "0.0.0.0/0", gateway_id = module.infra_prod_igw.id }]
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

module "infra_prod_ecs_cluster" {
  source       = "./modules/ecs_cluster"
  cluster_name = "infra-prod-ecs-cluster"
}

module "ecs_service_role" {
  source    = "./modules/iam_role"
  role_name = "infra-prod-ecs-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
      },
    ],
  })
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

module "infra_prod_backend_ecs_sg" {
  source              = "./modules/security_group"
  security_group_name = "infra-prod-backend-ecs-sg"
  vpc_id              = module.infra_prod_vpc.id

  ingress_rules = concat([
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [for subnet in local.private_subnets : subnet.cidr]
    }
  ])

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "infra_prod_frontend_ecs_sg" {
  source              = "./modules/security_group"
  security_group_name = "infra-prod-frontend-ecs-sg"
  vpc_id              = module.infra_prod_vpc.id

  ingress_rules = concat([
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [for subnet in local.public_subnets : subnet.cidr]
    }
  ])

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "infra_prod_backend_int_lb_sg" {
  source              = "./modules/security_group"
  security_group_name = "infra-prod-backend-int-lb-sg"
  vpc_id              = module.infra_prod_vpc.id

  ingress_rules = concat([
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [for subnet in local.private_subnets : subnet.cidr]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [for subnet in local.private_subnets : subnet.cidr]
    }
  ])

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "infra_prod_frontend_ext_lb_sg" {
  source              = "./modules/security_group"
  security_group_name = "infra-prod-frontend-ext-lb-sg"
  vpc_id              = module.infra_prod_vpc.id

  ingress_rules = concat([
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ])

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "infra_prod_backend_int_lb" {
  source                     = "./modules/alb"
  alb_name                   = "infra-prod-backend-int-lb"
  is_internal                = true
  vpc_id                     = module.infra_prod_vpc.id
  subnet_ids                 = [for subnet in module.infra_prod_private_subnets : subnet.id]
  security_group_ids         = [module.infra_prod_backend_int_lb_sg.id]
  enable_deletion_protection = false #Production-ready=true

  target_group_name        = "infra-prod-backend-tg"
  target_group_target_type = "ip"
  target_group_port        = 80
  target_group_protocol    = "HTTP"
  tg_tags                  = { "Name" = "infra-prod-backend-tg" }
  listener_port            = 80
  listener_protocol        = "HTTP"

  health_check = {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  deregistration_delay = 300

  listener_priority = 1

  listener_conditions = [
    {
      path_pattern = "/*"
    }
  ]
}

module "infra_prod_frontend_ext_lb" {
  source                     = "./modules/alb"
  alb_name                   = "infra-prod-frontend-ext-lb"
  is_internal                = false
  vpc_id                     = module.infra_prod_vpc.id
  subnet_ids                 = [for subnet in module.infra_prod_public_subnets : subnet.id]
  security_group_ids         = [module.infra_prod_frontend_ext_lb_sg.id]
  enable_deletion_protection = false #Production-ready=true
  target_group_name          = "infra-prod-frontend-tg"
  target_group_target_type   = "ip"
  target_group_port          = 80
  target_group_protocol      = "HTTP"
  tg_tags                    = { "Name" = "infra-prod-frontend-tg" }
  listener_port              = 80
  listener_protocol          = "HTTP"
  health_check = {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  deregistration_delay = 300

  listener_priority = 1

  listener_conditions = [
    {
      path_pattern = "/*"
    }
  ]
}

module "backend_ecs_task_definition" {
  source             = "./modules/ecs_task_definition"
  family             = "backend"
  network_mode       = "awsvpc"
  task_role_arn      = module.ecs_service_role.arn
  execution_role_arn = module.ecs_service_role.arn
  cpu                = "256"
  memory             = "512"
  container_definitions = [
    {
      name  = "backend"
      image = "nginx:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ]
}

module "frontend_ecs_task_definition" {
  source             = "./modules/ecs_task_definition"
  family             = "frontend"
  network_mode       = "awsvpc"
  task_role_arn      = module.ecs_service_role.arn
  execution_role_arn = module.ecs_service_role.arn
  cpu                = "256"
  memory             = "512"
  container_definitions = [
    {
      name  = "frontend"
      image = "nginx:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ]
}

module "frontend_ecs_service" {
  source          = "./modules/ecs_service"
  service_name    = "frontend-service"
  cluster_id      = module.infra_prod_ecs_cluster.cluster_id
  task_definition = module.frontend_ecs_task_definition.arn
  launch_type     = "FARGATE"
  subnets         = [for subnet in module.infra_prod_private_subnets : subnet.id]
  security_groups = [module.infra_prod_frontend_ecs_sg.id]
  desired_count   = 2
  load_balancers = [{
    target_group_arn = module.infra_prod_frontend_ext_lb.target_group_arn
    container_name   = "frontend"
    container_port   = 80
  }]
  depends_on = [module.infra_prod_frontend_ext_lb]
}

module "frontend_ecs_service_autoscaling" {
  source              = "./modules/ecs_autoscaling"
  service_name        = module.frontend_ecs_service.name
  cluster_name        = module.infra_prod_ecs_cluster.name
  min_capacity        = 3
  max_capacity        = 10
  target_utilization  = 70
  scale_down_cooldown = 400
  scale_up_cooldown   = 200
}

module "backend_ecs_service" {
  source          = "./modules/ecs_service"
  service_name    = "backend-service"
  cluster_id      = module.infra_prod_ecs_cluster.cluster_id
  task_definition = module.backend_ecs_task_definition.arn
  launch_type     = "FARGATE"
  subnets         = [for subnet in module.infra_prod_private_subnets : subnet.id]
  security_groups = [module.infra_prod_backend_ecs_sg.id]
  desired_count   = 2
  load_balancers = [{
    target_group_arn = module.infra_prod_backend_int_lb.target_group_arn
    container_name   = "backend"
    container_port   = 80
  }]
  depends_on = [module.infra_prod_backend_int_lb]
}

module "backend_ecs_service_autoscaling" {
  source              = "./modules/ecs_autoscaling"
  service_name        = module.backend_ecs_service.name
  cluster_name        = module.infra_prod_ecs_cluster.name
  min_capacity        = 3
  max_capacity        = 10
  target_utilization  = 70
  scale_down_cooldown = 400
  scale_up_cooldown   = 200
}
