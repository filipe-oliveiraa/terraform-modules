# S3 Static Site Module

Creates a private S3 bucket for static site hosting, a CloudFront distribution with Origin Access Control (OAC), optional aliases/ACM, managed cache/origin/headers policies, logging, and optional edge integrations (Lambda@Edge / CloudFront Functions).

## Requirements / Assumptions
- Bucket and CloudFront are in the same AWS account; ACM certificate (if used) must be in `us-east-1` for CloudFront.
- Versioning is enabled by default; you can disable via input.
- For custom domains, provide an ACM cert ARN in `acm_certificate_arn` and create Route 53 records pointing at `cloudfront_domain_name`.
- Lambda@Edge functions must be deployed in `us-east-1`.

## Inputs
- `bucket_name` (string, required): Unique name for the static website bucket.
- `bucket_force_destroy` (bool, default `false`): Allow bucket destroy with objects.
- `enable_bucket_versioning` (bool, default `true`): Toggle versioning.
- `enable_website_configuration` (bool, default `true`): Create S3 website index/error docs.
- `index_document` (string, default `index.html`): Website index.
- `error_document` (string, default `index.html`): Website error doc.
- `sse_algorithm` (string, default `AES256`): `AES256` or `aws:kms`.
- `sse_kms_key_arn` (string, default `null`): Required when `sse_algorithm = aws:kms`.
- `tags` (map(string), default `{}`): Tags for all resources.

CloudFront core:
- `aliases` (list(string), default `[]`): Alternate domain names.
- `acm_certificate_arn` (string, default `null`): ACM cert ARN (us-east-1). If null, uses default CloudFront cert.
- `ssl_support_method` (string, default `sni-only`): `sni-only` or `vip`.
- `minimum_protocol_version` (string, default `TLSv1.2_2021`).
- `price_class` (string, default `PriceClass_100`).
- `cloudfront_comment` (string, default `null`).
- `default_root_object` (string, default `index.html`).
- `default_cache_behavior_ttl` (object, default `{min=0,default=86400,max=31536000}`).
- `custom_error_responses` (list(object), default `[]`).
- `geo_restriction` (object, default `{type="none",locations=[]}`).
- `waf_web_acl_arn` (string, default `null`).
- `wait_for_deployment` (bool, default `true`).

Policies and headers:
- `cache_policy_id` (string, default `null`): Use AWS managed CachingOptimized when null.
- `origin_request_policy_id` (string, default `null`): Use AWS managed CORS-S3Origin when null.
- `response_headers_policy_id` (string, default `null`): Use AWS managed SecurityHeaders when null and `enable_default_security_headers` is true.
- `enable_default_security_headers` (bool, default `true`).

Logging:
- `logging_bucket` (string, default `null`): Target bucket domain for access logs.
- `logging_prefix` (string, default `cloudfront/`).
- `logging_include_cookies` (bool, default `false`).

Edge integrations:
- `lambda_function_associations` (list(object), default `[]`): `{event_type, lambda_arn, include_body?}` events: viewer-request/response, origin-request/response.
- `cloudfront_function_associations` (list(object), default `[]`): `{event_type, function_arn}` events: viewer-request/response.

## Outputs
- Bucket: `bucket_id`, `bucket_arn`, `bucket_domain_name`, `bucket_website_endpoint`, `bucket_regional_domain_name`, `bucket_hosted_zone_id`.
- CloudFront: `cloudfront_distribution_id`, `cloudfront_distribution_arn`, `cloudfront_domain_name`, `cloudfront_hosted_zone_id`.
- OAC: `origin_access_control_id`.

## Example (custom domain with ACM)
```hcl
module "s3_static_site" {
  source = "../../modules/s3_static_site"

  bucket_name = "my-static-site-bucket"

  aliases             = ["app.example.com"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abcd-1234"

  logging_bucket = "logs-bucket.s3.amazonaws.com" #Can be = []
  logging_prefix = "cloudfront/"

  lambda_function_associations = []
  cloudfront_function_associations = []

  tags = {
    Project = "web"
    Env     = "prod"
  }
}
```

## Example (basic, no custom domain)
```hcl
module "s3_static_site" {
  source      = "../../modules/s3_static_site"
  bucket_name = "my-basic-site"

  aliases             = []
  acm_certificate_arn = null

  tags = {
    Project = "web"
    Env     = "dev"
  }
}
```
