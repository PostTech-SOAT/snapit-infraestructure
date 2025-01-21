resource "aws_subnet" "private_subnet" {
  for_each   = { for key, value in var.private_zone : key => value }
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr_block

  availability_zone = "${var.aws_region}${each.value.availability_zone}"

  tags = {
    Name = format("%s-${each.key}", var.application)
    Tier = "private"
  }
}
resource "aws_route_table_association" "private" {
  for_each       = var.private_zone
  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.nat.id
}
