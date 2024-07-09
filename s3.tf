resource "aws_s3_bucket" "hosting_bucket" {
  bucket = var.hosting_bucket_name

  tags = {
    Environment = "Dev"
  }
}
