variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "ssh_inbound" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

variable "key_pair_name" {
  type = string
}

locals {
  cluster_name      = "glue-example"
  kafka_version     = "3.2.0"
  cluster_node_type = "kafka.t3.small"
  ami               = "amzn2-ami-kernel-5.10-hvm-2.0.20221210.1-x86_64-gp2"
}

data "aws_availability_zones" "available" {
  state = "available"
}