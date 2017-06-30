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
  count             = 1
  key_name          = "${var.key_name}"
  ami               = "${data.aws_ami.centos7.id}"
  instance_type     = "${var.instype}"
  user_data         = "${file("${path_to_file}")}"
  availability_zone = "${var.avzone}"
  subnet_id         = "${var.subnet_id}"

  tags {
    Name = "Puppet Master"
  }
}
