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
  subnet_id                   = "${var.subnet_id}"
  associate_public_ip_address = true

  provisioner "puppet_config" {
   source      = "${path.module}/${var.path_to_file}"
   destination = "/tmp/puppet_config.sh"
 }

 provisioner "local-exec" {
   inline = [
     "chmod +x /tmp/puppet_config.sh",
     "sudo /tmp/puppet_config.sh ",
   ]
 }


  tags {
    Name = "Puppet Master"
  }
}
