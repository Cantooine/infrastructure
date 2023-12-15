output "arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.tg.arn
}

output "name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.tg.name
}
