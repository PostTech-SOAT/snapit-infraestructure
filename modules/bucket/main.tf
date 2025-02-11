resource "aws_s3_bucket" "example" {
  for_each = var.buckets_sufix_name
  bucket   = "${var.application}-${each.value}"

  tags = {
    Name = "${var.application}-${each.value}"
  }
}
