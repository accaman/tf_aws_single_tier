variable "name_prefix" { }
variable "vpc"         { }
variable "multi_az"    { }
variable "azs"         { type = "list" }
variable "subnets"     { type = "list" }

module "vpc" {
  source = "./vpc"

  name_prefix = "${var.name_prefix}"
  cidr        = "${var.vpc}"
}

module "subnet" {
  source   = "./subnet"

  name_prefix = "${var.name_prefix}"
  vpc_id      = "${module.vpc.id}"
  multi_az    = "${var.multi_az}"
  azs         = "${var.azs}"
  cidrs       = "${var.subnets}"
}

output "vpc_id" {
  value = "${module.vpc.id}"
}

output "subnet_ids" {
  value = "${module.subnet.ids}"
}
