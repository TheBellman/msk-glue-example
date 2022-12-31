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
