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

data "template_file" "userdata" {
  template = "${file("${path.module}/${var.path_to_file}")}"
}

resource "aws_instance" "puppetserver" {
  count                       = 1
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.centos7.id}"
  instance_type               = "${var.instype}"
  user_data                   = "${data.template_file.userdata.rendered}"
  subnet_id                   = "${element(var.subnet_id, count.index)}"
  security_groups             = ["${aws_security_group.puppetserver}"]
  depends_on                  = ["aws_security_group.puppetserver"]

  tags {
    Name = "Puppet Master"
  }
}

resource "aws_security_group" "puppetserver" {
    vpc_id = "${var.vpc_id}"
    description = "Allow egress and ssh/puppet traffic"

    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${var.pub_net}"]
    }

    ingress {
      from_port   = 8140
      to_port     = 8140
      protocol    = "tcp"
      cidr_blocks = ["${var.pub_net}"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}
