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
  private_ip                  = "${var.vpc_netprefix}.${var.priv_sn_netnumber}0.${var.puppet_addr}"
  security_groups             = ["${aws_security_group.puppetserver.id}"]
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
      cidr_blocks = ["${var.pub_net}", "${var.vpc_netprefix}.${var.priv_sn_netnumber}0.0/${var.priv_sn_netmask}"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port   = 2181
      to_port     = 2181
      protocol    = "tcp"
      cidr_blocks = ["${var.vpc_netprefix}.${var.priv_sn_netnumber}0.0/${var.priv_sn_netmask}"]
    }
    ingress {
      from_port   = 3888
      to_port     = 3888
      protocol    = "tcp"
      cidr_blocks = ["${var.vpc_netprefix}.${var.priv_sn_netnumber}0.0/${var.priv_sn_netmask}"]
    }
    ingress {
      from_port   = 2888
      to_port     = 2888
      protocol    = "tcp"
      cidr_blocks = ["${var.vpc_netprefix}.${var.priv_sn_netnumber}0.0/${var.priv_sn_netmask}"]
    }
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["${var.pub_net}"]
    }
    ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["${var.pub_net}"]
    }
    ingress {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["${var.vpc_netprefix}.${var.priv_sn_netnumber}0.0/${var.priv_sn_netmask}"]
    }
}
