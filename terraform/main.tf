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
  cluster_name  = local.cluster_name
  kafka_version = local.kafka_version
  # One broker in each AZ
  number_of_broker_nodes = length(data.aws_availability_zones.available.zone_ids)

  broker_node_group_info {
    instance_type = local.cluster_node_type

    # This specifies what subnets the cluster will be built into
    client_subnets = tolist(module.vpc.private_subnet_id)

    # This is the security group that controls where requests can come from
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