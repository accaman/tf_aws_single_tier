variable "prefix" {}

variable "region" {}

variable "vpc" {}

variable "az_count" {}

variable "azs" {
  type = "list"
}

variable "subnets" {
  type = "list"
}

variable "public_key" {}

variable "key_name" {}

variable "bastion_amis" {
  type = "map"

  default = {
    us-west-2      = "ami-f173cc91"
    ap-northeast-1 = "ami-56d4ad31"
  }
}

variable "bastion_instance_type" {
  default = "t2.micro"
}

variable "bastion_sg_whitelist" {
  type    = "list"
  default = ["0.0.0.0/0"]
}

provider "aws" {
  region = "${var.region}"
}

module "network" {
  source = "./network"

  prefix   = "${var.prefix}"
  vpc      = "${var.vpc}"
  az_count = "${var.az_count}"
  azs      = "${var.azs}"
  subnets  = "${var.subnets}"
}

module "compute" {
  source = "./compute"

  prefix                = "${var.prefix}"
  region                = "${var.region}"
  vpc_id                = "${module.network.vpc_id}"
  az_count              = "${var.az_count}"
  subnet_ids            = "${module.network.subnet_ids}"
  key_name              = "${var.key_name}"
  public_key            = "${var.public_key}"
  bastion_ami           = "${lookup(var.bastion_amis, var.region)}"
  bastion_instance_type = "${var.bastion_instance_type}"
  bastion_sg_whitelist  = "${var.bastion_sg_whitelist}"
}

output "vpc_id" {
  value = "${module.network.vpc_id}"
}

output "subnet_ids" {
  value = "${module.network.subnet_ids}"
}

output "bastion_ids" {
  value = "${module.compute.bastion_ids}"
}

output "bastion_eips" {
  value = "${module.compute.bastion_eips}"
}
