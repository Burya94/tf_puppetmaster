output "ami_id" {
  value = "${data.aws_ami.centos7.id}"
}
output "aws_ip" {
  value = "${aws_instance.puppetserver.public_ip}"
}
