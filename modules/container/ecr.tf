resource "aws_ecr_repository" "snapit_ecr" {
  name = "${var.application}-ecr"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "IMMUTABLE"

  tags = {
    Name = "${var.application}-ecr"
  }
}
