variable "prefix" {}

variable "vpc" {}

variable "az_count" {}

variable "azs" {
  type = "list"
}

variable "subnets" {
  type = "list"
}

module "vpc" {
  source = "./vpc"

  prefix = "${var.prefix}"
  cidr   = "${var.vpc}"
}

module "subnet" {
  source = "./subnet"

  prefix   = "${var.prefix}"
  vpc_id   = "${module.vpc.id}"
  az_count = "${var.az_count}"
  azs      = "${var.azs}"
  cidrs    = "${var.subnets}"
}

output "vpc_id" {
  value = "${module.vpc.id}"
}

output "subnet_ids" {
  value = "${module.subnet.ids}"
}
