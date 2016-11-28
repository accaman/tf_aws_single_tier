variable "name_prefix" { }
variable "cidr"        { }

resource "aws_vpc" "default" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.name_prefix}-vpc"
  }
}

output "id" {
  value = "${aws_vpc.default.id}"
}
