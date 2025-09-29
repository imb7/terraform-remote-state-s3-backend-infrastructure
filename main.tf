# Terraform configuration for S3 bucket to store Terraform remote state
# Create an S3 bucket with versioning, encryption, and lifecycle policies

resource "aws_s3_bucket" "remote_state_bucket" {
  bucket = "${var.project_name}-${var.environment_name}-${var.owner}-remote-backend" # interpolated variable for unique bucket name

  # delete the bucket and all its objects without any need for mannual emptying.
  force_destroy = true
}

# Ensure the bucket is not publicly accessible
resource "aws_s3_bucket_public_access_block" "remote_state_public_access" {
  bucket = aws_s3_bucket.remote_state_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Enable server-side encryption using AES256
resource "aws_s3_bucket_server_side_encryption_configuration" "remote_state_encryption" {
  bucket = aws_s3_bucket.remote_state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable versioning on the bucket
resource "aws_s3_bucket_versioning" "remote_state_versioning" {
  bucket = aws_s3_bucket.remote_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure lifecycle policy to manage noncurrent versions
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