variable "region" {}
variable "key_name" {}
variable "instype" {}
variable "path_to_file" { default = "./puppet.sh"}
variable "subnet_id" { type = "list" }
variable "vpc_id" {}
variable "pub_net" {}
