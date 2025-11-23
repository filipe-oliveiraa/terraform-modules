# ------------------------------
# Shared locals and data sources
# ------------------------------
locals {
  origin_id = "${var.bucket_name}-s3-origin"

  cloudfront_comment = coalesce(
    var.cloudfront_comment,
    "Static site distribution for ${var.bucket_name}"
  )

  cache_policy_id = var.cache_policy_id != null ? var.cache_policy_id : data.aws_cloudfront_cache_policy.caching_optimized[0].id

  origin_request_policy_id = var.origin_request_policy_id != null ? var.origin_request_policy_id : data.aws_cloudfront_origin_request_policy.s3_cors[0].id

  response_headers_policy_id = var.response_headers_policy_id != null ? var.response_headers_policy_id : (
    var.enable_default_security_headers ? data.aws_cloudfront_response_headers_policy.security_headers[0].id : null
  )
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  count = var.cache_policy_id == null ? 1 : 0
  name  = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "s3_cors" {
  count = var.origin_request_policy_id == null ? 1 : 0
  name  = "Managed-CORS-S3Origin"
}

data "aws_cloudfront_response_headers_policy" "security_headers" {
  count = var.enable_default_security_headers && var.response_headers_policy_id == null ? 1 : 0
  name  = "Managed-SecurityHeadersPolicy"
}

# ------------------------------
# S3 bucket resources
# ------------------------------
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.bucket_force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_bucket_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.sse_kms_key_arn : null
    }
  }
}

resource "aws_s3_bucket_website_configuration" "this" {
  count  = var.enable_website_configuration ? 1 : 0
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

# ------------------------------
# CloudFront OAC + distribution
# ------------------------------
resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.bucket_name}-oac"
  description                       = "Origin Access Control for ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  aliases             = var.aliases
  comment             = local.cloudfront_comment
  default_root_object = var.default_root_object
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = var.price_class
  http_version        = "http2and3"
  wait_for_deployment = var.wait_for_deployment
  tags                = var.tags
  web_acl_id          = var.waf_web_acl_arn

  origin {
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = local.origin_id
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = true
    cache_policy_id            = local.cache_policy_id
    origin_request_policy_id   = local.origin_request_policy_id
    response_headers_policy_id = local.response_headers_policy_id

    min_ttl     = var.default_cache_behavior_ttl.min
    default_ttl = var.default_cache_behavior_ttl.default
    max_ttl     = var.default_cache_behavior_ttl.max

    dynamic "lambda_function_association" {
      for_each = var.lambda_function_associations

      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = try(lambda_function_association.value.include_body, null)
      }
    }

    dynamic "function_association" {
      for_each = var.cloudfront_function_associations

      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses

    content {
      error_code            = custom_error_response.value.error_code
      response_code         = try(custom_error_response.value.response_code, null)
      response_page_path    = try(custom_error_response.value.response_page_path, null)
      error_caching_min_ttl = try(custom_error_response.value.error_caching_min_ttl, null)
    }
  }

  dynamic "logging_config" {
    for_each = var.logging_bucket == null ? [] : [var.logging_bucket]

    content {
      bucket          = logging_config.value
      include_cookies = var.logging_include_cookies
      prefix          = var.logging_prefix
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction.type
      locations        = var.geo_restriction.locations
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    cloudfront_default_certificate = var.acm_certificate_arn == null
    minimum_protocol_version       = var.minimum_protocol_version
    ssl_support_method             = var.acm_certificate_arn == null ? null : var.ssl_support_method
  }

  depends_on = [
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket_ownership_controls.this
  ]
}

# ------------------------------
# Bucket policy granting OAC access
# ------------------------------
data "aws_iam_policy_document" "oac_bucket_access" {
  statement {
    sid     = "AllowCloudFrontServicePrincipalReadOnly"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    resources = ["${aws_s3_bucket.this.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "oac" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.oac_bucket_access.json
}
