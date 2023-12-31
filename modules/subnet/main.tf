resource "aws_subnet" "subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.public

  tags = {
    Name = var.name
  }
}
