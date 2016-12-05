variable "prefix" {}

variable "region" {}

variable "az_count" {}

variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "key_name" {}

variable "public_key" {}

variable "bastion_ami" {}

variable "bastion_instance_type" {}

variable "bastion_sg_whitelist" {
  type = "list"
}

module "bastion" {
  source = "./bastion"

  prefix        = "${var.prefix}"
  vpc_id        = "${var.vpc_id}"
  az_count      = "${var.az_count}"
  subnet_ids    = "${var.subnet_ids}"
  key_name      = "${var.key_name}"
  public_key    = "${var.public_key}"
  ami           = "${var.bastion_ami}"
  instance_type = "${var.bastion_instance_type}"
  sg_whitelist  = "${var.bastion_sg_whitelist}"
}

output "bastion_ids" {
  value = "${module.bastion.ids}"
}

output "bastion_eips" {
  value = "${module.bastion.eips}"
}
