# outputs for the S3 bucket and DynamoDB table created for Terraform remote state management
output "s3_bucket_name" {
  description = "The name of the S3 bucket created for storing Terraform remote state"
  value       = aws_s3_bucket.remote_state_bucket.bucket
}
output "dynamodb_table_name" {
  description = "The name of the DynamoDB table created for Terraform state locking"
  value       = aws_dynamodb_table.remote_state_lock_table.name
}