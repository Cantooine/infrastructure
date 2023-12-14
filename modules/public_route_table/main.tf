resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  dynamic "route" {
    for_each = var.routes
    content {
      cidr_block     = route.value["cidr_block"]
      gateway_id     = lookup(route.value, "gateway_id", null)
      nat_gateway_id = lookup(route.value, "nat_gateway_id", null)
    }
  }

  tags = {
    Name = var.name
  }
}

resource "aws_route_table_association" "rt_association" {
  for_each       = var.subnet_ids
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = each.value
}
