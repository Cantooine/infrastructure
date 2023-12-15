resource "aws_lb_target_group" "tg" {
  name     = var.name
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = var.health_check["enabled"]
    path                = var.health_check["path"]
    port                = var.health_check["port"]
    protocol            = var.health_check["protocol"]
    interval            = var.health_check["interval"]
    timeout             = var.health_check["timeout"]
    healthy_threshold   = var.health_check["healthy_threshold"]
    unhealthy_threshold = var.health_check["unhealthy_threshold"]
  }

  deregistration_delay = var.deregistration_delay

  tags = var.tags
}
