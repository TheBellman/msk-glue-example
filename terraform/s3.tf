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
