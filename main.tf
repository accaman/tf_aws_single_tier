# network
variable "name_prefix" { }
variable "region"      { }
variable "vpc"         { }
variable "multi_az"    { }
variable "azs"         { type = "list" }
variable "subnets"     { type = "list" }

# credential
variable "key_name"   { }
variable "public_key" { }

# compute
variable "bastion_images" {
  type    = "map"
  default = {
    us-west-2      = "ami-81f62ce1"
    # ap-northeast-1 = "ami-a24cf8c3"
  }
}
variable "bastion_flavor" {
  default = "t2.micro"
}
variable "accepts_ssh_connection_for" {
  type    = "list"
  default = ["0.0.0.0/0"]
}

provider "aws" {
  region = "${var.region}"
}

module "network" {
  source = "./network"

  name_prefix = "${var.name_prefix}"
  vpc         = "${var.vpc}"
  multi_az    = "${var.multi_az}"
  azs         = "${var.azs}"
  subnets     = "${var.subnets}"
}

module "compute" {
  source = "./compute"

  name_prefix = "${var.name_prefix}"
  region      = "${var.region}"
  vpc_id      = "${module.network.vpc_id}"
  multi_az    = "${var.multi_az}"
  subnet_ids  = "${module.network.subnet_ids}"

  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"

  bastion_image              = "${lookup(var.bastion_images, var.region)}"
  bastion_flavor             = "${var.bastion_flavor}"
  accepts_ssh_connection_for = "${var.accepts_ssh_connection_for}"
}

output "vpc_id" {
  value = "${module.network.vpc_id}"
}

output "subnet_ids" {
  value = "${module.network.subnet_ids}"
}

output "bastion_id" {
  value = "${module.compute.bastion_id}"
}
