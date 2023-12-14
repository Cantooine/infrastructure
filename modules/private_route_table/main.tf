resource "aws_route_table" "private_rt" {
  for_each = var.subnets
  vpc_id   = var.vpc_id

  tags = {
    Name = "${var.vpc_name}-${each.key}-private-rt"
  }
}

resource "aws_route" "private_rt_route" {
  for_each               = var.subnets
  route_table_id         = aws_route_table.private_rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateways[each.key]
}

resource "aws_route_table_association" "private_rt_association" {
  for_each       = var.subnets
  route_table_id = aws_route_table.private_rt[each.key].id
  subnet_id      = each.value
}
