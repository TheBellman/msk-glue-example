# --------------------------------------------------------------------------------
# log group  
# --------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "dev" {
  name_prefix = "kafka_"

  retention_in_days = 7
  tags              = { Name = "Kafka" }
}

