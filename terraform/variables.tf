variable "aws_region" {
  description = "AWS region for S3 API calls. CloudFront is global, but the AWS provider still needs a region."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Optional local AWS CLI profile name."
  type        = string
  default     = null
}

variable "s3_bucket_name" {
  description = "Existing S3 bucket used as the CloudFront origin."
  type        = string
  default     = "skyskippers"
}

variable "cloudfront_distribution_id" {
  description = "Existing CloudFront distribution ID."
  type        = string
  default     = "E1VF9CL2NFX8KT"
}

