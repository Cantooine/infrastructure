output "id" {
  value = aws_vpc.main.id
}

output "name" {
  value = aws_vpc.main.tags["Name"]
}
