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
    "Version" : "2024-7-8",
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

# import website files by enumerating through each object and their attributes
resource "aws_s3_object" "hosting_bucket_files" {
  bucket = aws_s3_bucket.hosting_bucket.id

  for_each = module.template_files.files

  key          = each.key
  content_type = each.value.content_type

  source  = each.value.source_path
  content = each.value.content
  etag    = each.value.digests.md5
}
