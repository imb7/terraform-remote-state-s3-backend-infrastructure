resource "aws_s3_bucket" "remote_state_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "remote_state_public_access" {
  bucket = aws_s3_bucket.remote_state_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "remote_state_encryption" {
  bucket = aws_s3_bucket.remote_state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "remote_state_versioning" {
  bucket = aws_s3_bucket.remote_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "remote_state_lifecycle" {
  bucket = aws_s3_bucket.remote_state_bucket.id

  rule {
    id     = "noncurrent-cleanup"
    status = "Enabled"

    filter { prefix = "" }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_days
    }

    expiration {
      expired_object_delete_marker = true
    }
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}