# --------------------------------------------------------------------------------
# security group to be used by the cluster to allow incoming requests
# --------------------------------------------------------------------------------
resource "aws_security_group" "dev" {
  name        = "msk_dev"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for MSK cluster"
  tags        = { Name = "msk_dev" }
}

resource "aws_security_group_rule" "dev_kafka_in" {
  security_group_id = aws_security_group.dev.id
  type              = "ingress"
  from_port         = 9092
  to_port           = 9098
  protocol          = "tcp"
  cidr_blocks       = tolist(module.vpc.public_subnet)
}

resource "aws_security_group_rule" "dev_zk_in" {
  security_group_id = aws_security_group.dev.id
  type              = "ingress"
  from_port         = 2181
  to_port           = 2182
  protocol          = "tcp"
  cidr_blocks       = tolist(module.vpc.public_subnet)
}

# --------------------------------------------------------------------------------
# the security group for client instances needs to allow kafka requests out
# --------------------------------------------------------------------------------
resource "aws_security_group_rule" "dev_kafka_out" {
  security_group_id = module.vpc.public_sg
  type              = "egress"
  from_port         = 9082
  to_port           = 9098
  protocol          = "tcp"
  cidr_blocks       = tolist(module.vpc.private_subnet)
}

resource "aws_security_group_rule" "dev_zk_out" {
  security_group_id = module.vpc.public_sg
  type              = "egress"
  from_port         = 2181
  to_port           = 2182
  protocol          = "tcp"
  cidr_blocks       = tolist(module.vpc.private_subnet)
}
