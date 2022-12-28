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
}

resource "aws_security_group_rule" "dev_kafka_in" {
  security_group_id = aws_security_group.dev.id
  type              = "ingress"
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  cidr_blocks       = concat(tolist(module.vpc.public_subnet), var.ssh_inbound)
}

resource "aws_security_group_rule" "dev_zk_in" {
  security_group_id = aws_security_group.dev.id
  type              = "ingress"
  from_port         = 2181
  to_port           = 2181
  protocol          = "tcp"
  cidr_blocks       = concat(tolist(module.vpc.public_subnet), var.ssh_inbound)
}


# --------------------------------------------------------------------------------
# key used for encryption at rest
# --------------------------------------------------------------------------------
resource "aws_kms_key" "dev" {
  description             = "MKS encryption at rest"
  deletion_window_in_days = 7
  tags                    = { Name = "msk_demo" }
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
resource "aws_msk_cluster" "dev" {
  cluster_name           = local.cluster_name
  kafka_version          = local.kafka_version
  number_of_broker_nodes = length(data.aws_availability_zones.available.zone_ids)

  broker_node_group_info {
    instance_type  = local.cluster_node_type
    client_subnets = tolist(module.vpc.public_subnet_id)
    storage_info {
      ebs_storage_info {
        volume_size = 256
      }
    }
    security_groups = [aws_security_group.dev.id]
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