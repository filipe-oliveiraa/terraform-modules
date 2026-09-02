mock_provider "aws" {}

variables {
  bucket_name = "my-terraform-state"

  # Set for most runs so the access-logging check block stays quiet. The run
  # that deliberately leaves it off asserts the warning instead.
  access_log_bucket = "my-audit-logs"
}

run "bucket_name_reaches_the_resource" {
  command = plan

  assert {
    condition     = aws_s3_bucket.s3_bucket.bucket == "my-terraform-state"
    error_message = "bucket_name must be passed through unmodified."
  }
}

run "state_bucket_guardrails_are_on_by_default" {
  command = plan

  # This bucket holds Terraform state, so these four are the whole point of the
  # module rather than optional extras.
  assert {
    condition     = aws_s3_bucket_public_access_block.s3_bucket_public_access_block.block_public_acls == true
    error_message = "A state bucket must block public ACLs."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.s3_bucket_public_access_block.restrict_public_buckets == true
    error_message = "A state bucket must restrict public bucket policies."
  }

  assert {
    condition     = aws_s3_bucket_versioning.s3_bucket_versioning.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning must be on - it is what lets you recover a clobbered state file."
  }

  assert {
    condition     = aws_s3_bucket.s3_bucket.object_lock_enabled == true
    error_message = "Object lock must default to on for a state bucket."
  }
}

run "object_lock_can_be_declined" {
  command = plan

  variables {
    s3_bucket_optional = {
      object_lock_enabled = false
    }
  }

  # Regression test: this used to be hardcoded true, so a caller asking for
  # false silently got true - on a setting that cannot be undone afterwards.
  assert {
    condition     = aws_s3_bucket.s3_bucket.object_lock_enabled == false
    error_message = "An explicit object_lock_enabled = false must be honoured, not overridden."
  }
}

run "access_logging_is_opt_in_and_warns_when_off" {
  command = plan

  variables {
    access_log_bucket = null
  }

  assert {
    condition     = length(aws_s3_bucket_logging.s3_bucket_logging) == 0
    error_message = "Access logging must stay off until a target bucket is given - it costs storage."
  }

  # The check block is the "suggest, do not force" half: leaving logging off
  # must produce a warning, not an error, and must not stop the plan.
  expect_failures = [
    check.state_bucket_access_logging,
  ]
}

run "access_logging_wires_up_when_a_bucket_is_given" {
  command = plan

  variables {
    access_log_bucket = "my-audit-logs"
  }

  assert {
    condition     = aws_s3_bucket_logging.s3_bucket_logging[0].target_bucket == "my-audit-logs"
    error_message = "access_log_bucket must become the logging target."
  }

  assert {
    condition     = aws_s3_bucket_logging.s3_bucket_logging[0].target_prefix == "my-terraform-state/"
    error_message = "With no explicit prefix, logs must be namespaced under the bucket name."
  }
}
