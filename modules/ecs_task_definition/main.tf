resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.family
  network_mode             = var.network_mode
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["FARGATE"]
  container_definitions    = jsonencode(var.container_definitions)
}
