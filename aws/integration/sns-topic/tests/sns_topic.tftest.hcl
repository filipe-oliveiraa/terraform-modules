mock_provider "aws" {}

run "callable_with_no_inputs_at_all" {
  command = plan

  # sns_topic_optional defaults to {}, so the module must plan with zero inputs.
  assert {
    condition     = aws_sns_topic.sns_topic.fifo_topic != true
    error_message = "A topic must not silently default to FIFO."
  }
}

run "name_and_tags_flow_through" {
  command = plan

  variables {
    sns_topic_optional = {
      name         = "alerts"
      display_name = "Platform alerts"
      tags         = { Team = "platform" }
    }
  }

  assert {
    condition     = aws_sns_topic.sns_topic.name == "alerts"
    error_message = "name must come from sns_topic_optional."
  }

  assert {
    condition     = aws_sns_topic.sns_topic.tags["Team"] == "platform"
    error_message = "tags must come from sns_topic_optional."
  }
}

run "fifo_and_kms_options_flow_through" {
  command = plan

  variables {
    sns_topic_optional = {
      name                        = "orders.fifo"
      fifo_topic                  = true
      content_based_deduplication = true
      kms_master_key_id           = "alias/aws/sns"
    }
  }

  assert {
    condition     = aws_sns_topic.sns_topic.fifo_topic == true
    error_message = "fifo_topic must come from sns_topic_optional."
  }

  assert {
    condition     = aws_sns_topic.sns_topic.kms_master_key_id == "alias/aws/sns"
    error_message = "kms_master_key_id must come from sns_topic_optional."
  }
}
