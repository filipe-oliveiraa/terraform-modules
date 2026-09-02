mock_provider "aws" {}

variables {
  source_bucket          = "source-bucket"
  source_list_prefixes   = ["incoming/"]
  source_object_prefixes = ["incoming/"]
  dest_bucket            = "dest-bucket"
  dest_prefixes          = ["archive/"]
}

run "policy_scopes_to_the_named_buckets" {
  command = plan

  # The whole point of this module is a policy narrower than s3:* on *, so the
  # bucket names have to appear in the document.
  assert {
    condition     = strcontains(aws_iam_policy.policy.policy, "arn:aws:s3:::source-bucket")
    error_message = "The policy must scope to the source bucket by ARN."
  }

  assert {
    condition     = strcontains(aws_iam_policy.policy.policy, "arn:aws:s3:::dest-bucket")
    error_message = "The policy must scope to the destination bucket by ARN."
  }
}

run "prefixes_are_normalised_to_a_wildcard" {
  command = plan

  variables {
    # Deliberately inconsistent input: with and without a trailing slash, and
    # with an explicit /*. All three should normalise to the same shape.
    source_list_prefixes   = ["incoming"]
    source_object_prefixes = ["incoming/"]
    dest_prefixes          = ["archive/*"]
  }

  assert {
    condition     = strcontains(aws_iam_policy.policy.policy, "incoming/*")
    error_message = "A prefix given without a trailing slash must normalise to prefix/*."
  }

  assert {
    condition     = !strcontains(aws_iam_policy.policy.policy, "archive/*/*")
    error_message = "A prefix already ending in /* must not be double-suffixed."
  }
}

run "policy_is_valid_json" {
  command = plan

  assert {
    condition     = can(jsondecode(aws_iam_policy.policy.policy))
    error_message = "The rendered policy must be valid JSON."
  }
}
