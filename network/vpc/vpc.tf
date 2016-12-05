variable "prefix" {}

variable "cidr" {}

resource "aws_vpc" "default" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "${format("%s-vpc", var.prefix)}"
  }
}

output "id" {
  value = "${aws_vpc.default.id}"
}
