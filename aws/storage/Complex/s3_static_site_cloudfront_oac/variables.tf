# S3 bucket configuration
variable "bucket_name" {
  description = "Unique name for the static website bucket."
  type        = string
}

variable "bucket_force_destroy" {
  description = "Allow Terraform to remove all objects so the bucket can be destroyed."
  type        = bool
  default     = false
}

variable "enable_bucket_versioning" {
  description = "Enable versioning to protect assets from accidental deletes or overwrites."
  type        = bool
  default     = true
}

variable "enable_website_configuration" {
  description = "Create S3 website configuration to keep index and error documents aligned with CloudFront."
  type        = bool
  default     = true
}

variable "index_document" {
  description = "Default index document for the website configuration."
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Default error document for the website configuration."
  type        = string
  default     = "index.html"
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm applied to objects stored in the bucket."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "sse_algorithm must be either AES256 or aws:kms."
  }
}

variable "sse_kms_key_arn" {
  description = "KMS key ARN used when sse_algorithm is aws:kms."
  type        = string
  default     = null

  validation {
    condition     = var.sse_algorithm != "aws:kms" || var.sse_kms_key_arn != null
    error_message = "Provide sse_kms_key_arn when sse_algorithm is set to aws:kms."
  }
}

variable "tags" {
  description = "Common tags propagated to every resource created by this module."
  type        = map(string)
  default     = {}
}

# CloudFront configuration
variable "aliases" {
  description = "Optional CNAMEs for the CloudFront distribution."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN to enable HTTPS with a custom domain. When null, the default CloudFront certificate is used."
  type        = string
  default     = null
}

variable "ssl_support_method" {
  description = "SSL support method when a custom ACM certificate is used."
  type        = string
  default     = "sni-only"

  validation {
    condition     = contains(["sni-only", "vip"], var.ssl_support_method)
    error_message = "ssl_support_method must be either sni-only or vip."
  }
}

variable "minimum_protocol_version" {
  description = "Minimum TLS protocol version supported by CloudFront."
  type        = string
  default     = "TLSv1.2_2021"
}

variable "price_class" {
  description = "CloudFront price class that limits the edge locations used to serve the distribution."
  type        = string
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.price_class)
    error_message = "price_class must be PriceClass_100, PriceClass_200, or PriceClass_All."
  }
}

variable "cloudfront_comment" {
  description = "Optional description added to the distribution."
  type        = string
  default     = null
}

variable "default_root_object" {
  description = "Object served when a viewer requests the root URL."
  type        = string
  default     = "index.html"
}

variable "default_cache_behavior_ttl" {
  description = "Time-to-live values applied to the default cache behavior."
  type = object({
    min     = number
    default = number
    max     = number
  })
  default = {
    min     = 0
    default = 86400    # 1 day
    max     = 31536000 # 1 year
  }

  validation {
    condition = (
      var.default_cache_behavior_ttl.min <= var.default_cache_behavior_ttl.default &&
      var.default_cache_behavior_ttl.default <= var.default_cache_behavior_ttl.max
    )
    error_message = "TTL values must satisfy min <= default <= max."
  }
}

variable "custom_error_responses" {
  description = "Custom error response definitions for CloudFront."
  type = list(object({
    error_code            = number
    response_code         = optional(number)
    response_page_path    = optional(string)
    error_caching_min_ttl = optional(number)
  }))
  default = []
}

variable "geo_restriction" {
  description = "Geo restriction configuration controlling where the distribution can serve traffic."
  type = object({
    type      = string
    locations = list(string)
  })
  default = {
    type      = "none"
    locations = []
  }

  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.geo_restriction.type)
    error_message = "geo_restriction.type must be one of none, whitelist, or blacklist."
  }

  validation {
    condition     = var.geo_restriction.type != "none" || length(var.geo_restriction.locations) == 0
    error_message = "locations must be empty when geo_restriction.type is none."
  }
}

variable "waf_web_acl_arn" {
  description = "Optional AWS WAFv2 web ACL ARN associated with the CloudFront distribution."
  type        = string
  default     = null
}

variable "wait_for_deployment" {
  description = "Wait for the CloudFront distribution to finish deploying before Terraform exits."
  type        = bool
  default     = true
}

# CloudFront policy overrides
variable "cache_policy_id" {
  description = "Custom cache policy ID. When null, the AWS managed CachingOptimized policy is used."
  type        = string
  default     = null
}

variable "origin_request_policy_id" {
  description = "Custom origin request policy ID. When null, the AWS managed CORS-S3Origin policy is used."
  type        = string
  default     = null
}

variable "response_headers_policy_id" {
  description = "Custom response headers policy ID. When null, the managed SecurityHeaders policy can be attached when enable_default_security_headers is true."
  type        = string
  default     = null
}

variable "enable_default_security_headers" {
  description = "Attach AWS managed security headers response policy when a custom policy ID is not supplied."
  type        = bool
  default     = true
}

# CloudFront logging configuration
variable "logging_bucket" {
  description = "S3 bucket domain name (e.g., logs-bucket.s3.amazonaws.com) that receives CloudFront access logs."
  type        = string
  default     = null
}

variable "logging_prefix" {
  description = "Prefix applied to CloudFront access logs."
  type        = string
  default     = "cloudfront/"
}

variable "logging_include_cookies" {
  description = "Include cookie data within CloudFront access logs."
  type        = bool
  default     = false
}

# CloudFront edge compute integrations
variable "lambda_function_associations" {
  description = "Lambda@Edge associations applied to the default cache behavior. Lambda functions must be deployed in the us-east-1 region per AWS requirements."
  type = list(object({
    event_type   = string
    lambda_arn   = string
    include_body = optional(bool, false)
  }))
  default = []

  validation {
    condition = alltrue([
      for association in var.lambda_function_associations :
      contains(["viewer-request", "viewer-response", "origin-request", "origin-response"], association.event_type)
    ])
    error_message = "lambda_function_associations.event_type must be one of viewer-request, viewer-response, origin-request, or origin-response."
  }
}

variable "cloudfront_function_associations" {
  description = "CloudFront Functions attached to the default cache behavior."
  type = list(object({
    event_type   = string
    function_arn = string
  }))
  default = []

  validation {
    condition = alltrue([
      for association in var.cloudfront_function_associations :
      contains(["viewer-request", "viewer-response"], association.event_type)
    ])
    error_message = "cloudfront_function_associations.event_type must be viewer-request or viewer-response."
  }
}
