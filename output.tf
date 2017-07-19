output "ami_id" {
  value = "${data.aws_ami.centos7.id}"
}
output "public_ip" {
  value = "${aws_instance.puppetserver.public_ip}"
}
output "private_dns" {
  value = "${aws_instance.puppetserver.private_dns}"
}
output "private_ip" {
  value = "${aws_instance.puppetserver.private_ip}"
}
output "sec_group" {
  value = "${aws_security_group.puppetserver.id}"
}
