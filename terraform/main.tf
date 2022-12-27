# --------------------------------------------------------------------------------
# create a VPC
# --------------------------------------------------------------------------------
module "vpc" {
  source = "github.com/TheBellman/module-vpc"
  tags   = var.tags

  vpc_cidr    = var.vpc_cidr
  vpc_name    = var.vpc_name
  ssh_inbound = var.ssh_inbound
}

# --------------------------------------------------------------------------------
# create the MSK cluster to go into it
# --------------------------------------------------------------------------------
resource "aws_msk_serverless_cluster" "dev" {
  cluster_name = local.cluster_name
  depends_on   = [module.vpc]

  vpc_config {
	  # TODO include the public subnet ids
    subnet_ids         = module.vpc.private_subnet_id
    security_group_ids = [aws_security_group.dev.id]
  }

  client_authentication {
    sasl {
      iam {
        enabled = true
      }
    }
  }
}

resource "aws_security_group" "dev" {
  name        = "msk_dev"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for MSK cluster"
}

# TODO refine this to be cidr blocks for public subnets + our desktop 
resource "aws_security_group_rule" "dev_kafka_in" {
  security_group_id = aws_security_group.dev.id
  type              = "ingress"
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0", var.ssh_inbound[0]]
}


/*
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:Connect",
        "kafka-cluster:AlterCluster",
        "kafka-cluster:DescribeCluster"
      ],
      "Resource": "arn:aws:kafka:eu-west-1:889199313043:cluster/glue-example/b7ee0312-c74d-4543-80d4-048e46fbcb4a-s1"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:DescribeTopic",
        "kafka-cluster:CreateTopic",
        "kafka-cluster:WriteData",
        "kafka-cluster:ReadData"
      ],
      "Resource": "arn:aws:kafka:eu-west-1:889199313043:topic/glue-example/b7ee0312-c74d-4543-80d4-048e46fbcb4a-s1/<TOPIC_NAME_HERE>"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:AlterGroup",
        "kafka-cluster:DescribeGroup"
      ],
      "Resource": "arn:aws:kafka:eu-west-1:889199313043:group/glue-example/b7ee0312-c74d-4543-80d4-048e46fbcb4a-s1/<GROUP_NAME_HERE>"
    }
  ]
}
*/