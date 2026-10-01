output "bucket_arn" {
  description = "ARN of the bucket storing processed data."
  value       = aws_s3_bucket.data.arn
}

output "bucket_name" {
  description = "Name of the bucket storing processed data."
  value       = aws_s3_bucket.data.id
}