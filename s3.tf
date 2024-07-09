# Create s3 bucket
resource "aws_s3_bucket" "hosting_bucket" {
  bucket = var.hosting_bucket_name

  tags = {
    Environment = "Dev"
  }
}

# add Access control list to allow public read on the bucket
resource "aws_s3_bucket_acl" "hosting_bucket_acl" {
  bucket = aws_s3_bucket.hosting_bucket.id

  acl = "public-read"
}

# add policy to allow s3:GetObject for all files under the specified arn
resource "aws_s3_bucket_policy" "hosting_bucket_policy" {
  bucket = aws_s3_bucket.hosting_bucket.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${var.hosting_bucket_name}/*"
      }
    ]
  })
}

# add configuration for static website hosting
resource "aws_s3_bucket_website_configuration" "hosting_bucket_web_config" {
  bucket = aws_s3_bucket.hosting_bucket.id

  index_document {
    suffix = "index.html"
  }
}
