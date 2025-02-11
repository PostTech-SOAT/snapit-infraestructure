resource "aws_subnet" "public_subnet" {
  for_each   = { for key, value in var.public_zone : key => value }
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr_block

  map_public_ip_on_launch = true

  availability_zone = "${var.aws_region}${each.value.availability_zone}"

  tags = {
    Name = format("%s-${each.key}", var.application)
    Tier = "public"
  }
}
resource "aws_route_table_association" "public" {
  for_each       = var.public_zone
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.igw_route_table.id
}
