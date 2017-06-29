provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "${var.region}"
}

data "aws_ami" "centos7"{
  most_recent = true

  filter{
    name  = "name"
    values = ["RHEL-7.3_HVM-20170613-x86_64*"]
  }

  filter{
    name  = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "puppetserver" {
  key_name      = "${var.key_name}"
  ami           = "${data.aws_ami.centos7.id}"
  instance_type = "${var.instype}"
  user_data     = "${file("./puppet.sh")}"

  tags {
    Name = "Puppet Master"
  }
}
