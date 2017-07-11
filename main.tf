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
  count                       = 1
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.centos7.id}"
  instance_type               = "${var.instype}"
  user_data                   = "${file("${path.module}/${var.path_to_file}")}"
  subnet_id                   = "${var.subnet_id}"
  associate_public_ip_address = "${var.pub_ip}"

  tags {
    Name = "Puppet Master"
  }
}
