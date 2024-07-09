# Create s3 bucket
resource "aws_s3_bucket" "hosting_bucket" {
  bucket = var.hosting_bucket_name

  tags = {
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "hosting_bucket_ownership_controls" {
  bucket = aws_s3_bucket.hosting_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "hosting_bucket_public_access_block" {
  bucket = aws_s3_bucket.hosting_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# add Access control list to allow public read on the bucket
resource "aws_s3_bucket_acl" "hosting_bucket_acl" {
  # add dependencies from documentation
  depends_on = [
    aws_s3_bucket_ownership_controls.hosting_bucket_ownership_controls,
    aws_s3_bucket_public_access_block.hosting_bucket_public_access_block,
  ]

  bucket = aws_s3_bucket.hosting_bucket.id
  acl    = "public-read"
}

# add policy to allow s3:GetObject for all data specified
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.hosting_bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:*",
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
