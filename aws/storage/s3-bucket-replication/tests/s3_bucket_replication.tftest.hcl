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
  source_bucket_id       = "source-bucket"
  source_bucket_arn      = "arn:aws:s3:::source-bucket"
  destination_bucket_id  = "dest-bucket"
  destination_bucket_arn = "arn:aws:s3:::dest-bucket"
  replication_role_name  = "s3-replication"

  replication_rules = [
    { id = "everything" },
  ]
}

run "replication_role_is_named_as_asked" {
  command = plan

  assert {
    condition     = aws_iam_role.replication.name == "s3-replication"
    error_message = "replication_role_name must be passed through unmodified."
  }
}

run "rules_reach_the_replication_configuration" {
  command = plan

  assert {
    condition     = length(aws_s3_bucket_replication_configuration.this.rule) == 1
    error_message = "One rule in must be one rule out."
  }

  assert {
    condition     = aws_s3_bucket_replication_configuration.this.rule[0].id == "everything"
    error_message = "The rule id must be passed through unmodified."
  }
}

run "replication_is_enabled_by_default_and_delete_markers_are_not" {
  command = plan

  # enable_replication defaults true (a disabled rule is a strange thing to
  # create), while delete-marker replication defaults false because it
  # propagates deletions to the destination - not what most people want from a
  # backup copy.
  assert {
    condition     = aws_s3_bucket_replication_configuration.this.rule[0].status == "Enabled"
    error_message = "A rule must default to Enabled."
  }

  assert {
    condition     = aws_s3_bucket_replication_configuration.this.rule[0].delete_marker_replication[0].status == "Disabled"
    error_message = "Delete-marker replication must stay off by default - it propagates deletions to the destination."
  }
}

run "multiple_rules_are_kept_distinct" {
  command = plan

  variables {
    replication_rules = [
      { id = "images", filter_prefix = "images/", priority = 1 },
      { id = "docs", filter_prefix = "docs/", priority = 2 },
    ]
  }

  assert {
    condition     = length(aws_s3_bucket_replication_configuration.this.rule) == 2
    error_message = "Two rules in must be two rules out."
  }
}
