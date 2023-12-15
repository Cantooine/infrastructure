output "cluster_arn" {
  value = aws_ecs_cluster.cluster.arn
}

output "cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "name" {
  value = aws_ecs_cluster.cluster.name
}
