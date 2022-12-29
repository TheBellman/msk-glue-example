# --------------------------------------------------------------------------------
# report some interesting facts
# --------------------------------------------------------------------------------
output "vpc_arn" {
  value = module.vpc.vpc_arn
}

output "public_subnet" {
  value = module.vpc.public_subnet
}

output "private_subnet" {
  value = module.vpc.private_subnet
}

output "eip_public_address" {
  value = module.vpc.eip_public_address
}

output "bootstraps" {
  value = aws_msk_cluster.dev.bootstrap_brokers_tls
}

output "zookeeper" {
  value = aws_msk_cluster.dev.zookeeper_connect_string
}

output "instance_id" {
  value = aws_instance.dev.id
}

output "instance_ip" {
  value = aws_instance.dev.public_ip
}