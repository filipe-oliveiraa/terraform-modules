mock_provider "aws" {
  # The provider validates that these are real JSON policy documents, and the
  # mock's default random string is not, so give it a valid empty policy.
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  bucket_name = "my-static-site"

  # Set so the access-logging check block stays quiet. The run that leaves it
  # off asserts the warning instead.
  logging_bucket = "my-cf-logs.s3.amazonaws.com"
}

run "bucket_is_private_and_encrypted_by_default" {
  command = plan

  # This is a Complex module, so unlike the Simple wrappers it is supposed to
  # come with guardrails rather than mirror the provider. These four are them.
  assert {
    condition = (
      aws_s3_bucket_public_access_block.this.block_public_acls == true &&
      aws_s3_bucket_public_access_block.this.block_public_policy == true &&
      aws_s3_bucket_public_access_block.this.ignore_public_acls == true &&
      aws_s3_bucket_public_access_block.this.restrict_public_buckets == true
    )
    error_message = "The origin bucket must be fully private - CloudFront reaches it through OAC, not through public access."
  }

  # rule is a set, not a list, so it cannot be indexed - hence the for
  # expression rather than [0].
  assert {
    condition = anytrue([
      for rule in aws_s3_bucket_server_side_encryption_configuration.this.rule :
      anytrue([
        for sse in rule.apply_server_side_encryption_by_default :
        sse.sse_algorithm == "AES256"
      ])
    ])
    error_message = "The bucket must be encrypted at rest by default."
  }
}

run "origin_access_control_is_used" {
  command = plan

  # OAC is what allows the bucket to stay private. If this regressed to a public
  # bucket policy or a legacy OAI, the guardrail above would be pointless.
  assert {
    condition     = aws_cloudfront_origin_access_control.this.signing_behavior == "always"
    error_message = "OAC must always sign origin requests."
  }

  assert {
    condition     = aws_cloudfront_origin_access_control.this.origin_access_control_origin_type == "s3"
    error_message = "OAC must be configured for an S3 origin."
  }
}

run "viewer_traffic_is_redirected_to_https" {
  command = plan

  assert {
    condition     = aws_cloudfront_distribution.this.default_cache_behavior[0].viewer_protocol_policy != "allow-all"
    error_message = "The distribution must not serve plain HTTP to viewers."
  }
}

run "access_logging_warns_when_off" {
  command = plan

  variables {
    logging_bucket = null
  }

  assert {
    condition     = length(aws_cloudfront_distribution.this.logging_config) == 0
    error_message = "No logging_bucket must mean no logging_config block."
  }

  # Warning, not error: logging costs money, so the module raises the question
  # and still lets the plan through.
  expect_failures = [
    check.cloudfront_access_logging,
  ]
}
