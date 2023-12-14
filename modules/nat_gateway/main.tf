resource "aws_eip" "nat_eip" {
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.public_subnet_id

  tags = {
    Name = "${var.vpc_name}-natgw-${var.availability_zone}"
  }

  depends_on = [aws_eip.nat_eip]
}
