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
  subnet_id                   = "${var.subnet_id}"
  associate_public_ip_address = true

  provisioner "file" {
   source      = "${path.module}/${var.path_to_file}"
   destination = "/root/puppet.sh"
 }

 provisioner "remote-exec" {
   inline = [
     "chmod +x /root/puppet.sh",
     "sudo /root/puppet.sh ",
   ]
 }


  tags {
    Name = "Puppet Master"
  }
}
