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

locals {
  cluster_name      = "glue-example"
  kafka_version     = "3.2.0"
  cluster_node_type = "kafka.t3.small"
}

data "aws_availability_zones" "available" {
  state = "available"
}