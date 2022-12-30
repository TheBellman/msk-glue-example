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
# the security group for instances needs to allow kafka requests out
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

# --------------------------------------------------------------------------------
# key used for encryption at rest
# --------------------------------------------------------------------------------
resource "aws_kms_key" "dev" {
  description             = "MSK encryption at rest"
  deletion_window_in_days = 7
  tags                    = { Name = "msk_demo" }
}

resource "aws_kms_alias" "dev" {
  name          = "alias/msk"
  target_key_id = aws_kms_key.dev.key_id
}

# --------------------------------------------------------------------------------
# bucket for logging 
# --------------------------------------------------------------------------------
resource "aws_s3_bucket" "logs" {
  bucket_prefix = "kafka-logs-"

  force_destroy = true

  tags = { "Name" = "Kafka Logs" }
}

resource "aws_s3_bucket_acl" "logs" {
  bucket = aws_s3_bucket.logs.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --------------------------------------------------------------------------------
# log group  
# --------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "dev" {
  name_prefix = "kafka_"

  retention_in_days = 7
  tags              = { Name = "Kafka" }
}


# --------------------------------------------------------------------------------
# create the MSK cluster 
# --------------------------------------------------------------------------------
resource "aws_msk_configuration" "dev" {
  kafka_versions = [local.kafka_version]
  name           = local.cluster_name

  server_properties = <<PROPERTIES
auto.create.topics.enable = true
delete.topic.enable = true
PROPERTIES
}

resource "aws_msk_cluster" "dev" {
  cluster_name           = local.cluster_name
  kafka_version          = local.kafka_version
  number_of_broker_nodes = length(data.aws_availability_zones.available.zone_ids)

  broker_node_group_info {
    instance_type   = local.cluster_node_type
    client_subnets  = tolist(module.vpc.private_subnet_id)
    security_groups = [aws_security_group.dev.id]

    # without specifying a client_authentication block, there's no client authentication required
    storage_info {
      ebs_storage_info {
        volume_size = 100
      }
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.dev.arn
    revision = 1
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.dev.arn
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.dev.name
      }
      s3 {
        enabled = true
        bucket  = aws_s3_bucket.logs.id
        prefix  = "logs/msk"
      }
    }
  }
}