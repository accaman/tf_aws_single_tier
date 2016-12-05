variable "prefix" {}

variable "vpc_id" {}

variable "az_count" {}

variable "azs" {
  type = "list"
}

variable "cidrs" {
  type = "list"
}

resource "aws_subnet" "ext" {
  count                   = "${var.az_count}"
  vpc_id                  = "${var.vpc_id}"
  availability_zone       = "${element(var.azs, count.index % var.az_count)}"
  cidr_block              = "${element(var.cidrs, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${format("%s-external-subnet%02d", var.prefix, count.index + 1)}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_route_table" "ext" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.prefix}-external-tbl"
  }
}

resource "aws_route" "ext_r" {
  route_table_id         = "${aws_route_table.ext.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_route_table_association" "ext_a" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.ext.*.id, count.index)}"
  route_table_id = "${aws_route_table.ext.id}"
}

output "ids" {
  value = ["${aws_subnet.ext.*.id}"]
}
