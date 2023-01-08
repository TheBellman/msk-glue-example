# ------------------------------------------------------------------------------------------------
# AWS Glue bits and pieces
# ------------------------------------------------------------------------------------------------
resource "aws_glue_registry" "kafka_test" {
  registry_name = "kafka-test"
  description   = "Throw away registry that can be used for testing and developing with Avro"
}
