variable "prefix" {}

variable "vpc_id" {}

variable "key_name" {}

variable "public_key" {}

variable "az_count" {}

variable "subnet_ids" {
  type = "list"
}

variable "ami" {}

variable "instance_type" {}

variable "sg_whitelist" {
  type = "list"
}

resource "aws_key_pair" "default" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}

resource "aws_security_group" "bastion" {
  vpc_id      = "${var.vpc_id}"
  name        = "${format("%s-bastion-sg", var.prefix)}"
  description = "Security Group for GHE Instance"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = "${var.sg_whitelist}"
  }

  ingress {
    protocol    = "icmp"
    from_port   = 8
    to_port     = 8
    cidr_blocks = "${var.sg_whitelist}"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  count = "${var.az_count}"

  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${element(var.subnet_ids, count.index % var.az_count)}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
  key_name               = "${var.key_name}"

  user_data = <<EOF
#!/bin/bash

curl -fsSL https://gist.githubusercontent.com/accaman/a57f23e41fb8e2c30a22ada3460ee650/raw/56d9ce075bc8d1a1c643909abd9b32f16c25c5b7/base.sh | sudo bash
EOF

  tags {
    Name = "${format("%s-bastion%02d", var.prefix, count.index + 1)}"
  }
}

resource "aws_eip" "bastion" {
  count = "${var.az_count}"
  vpc   = true
}

resource "aws_eip_association" "bastion_a" {
  count = "${var.az_count}"

  allocation_id = "${element(aws_eip.bastion.*.id, count.index)}"
  instance_id   = "${element(aws_instance.bastion.*.id, count.index)}"
}

output "ids" {
  value = ["${aws_instance.bastion.*.id}"]
}

output "eips" {
  value = ["${aws_eip.bastion.*.public_ip}"]
}
