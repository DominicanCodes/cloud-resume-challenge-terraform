variable "aws_region" {
  type        = string
  description = "AWS region to use for resources."
  default     = "us-east-1"
}

variable "hosting_bucket_name" {
  type        = string
  description = "Name of the hosting bucket."
}
