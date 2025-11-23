locals {
  delete_marker_replication_status = "Disabled" # per rule override below
  replication_status               = "Enabled"  # per rule override below
}

data "aws_iam_policy_document" "replication_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "replication_permissions" {
  statement {
    sid    = "SourceAccess"
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources = [var.source_bucket_arn]
  }

  statement {
    sid    = "SourceObjectAccess"
    effect = "Allow"
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"
    ]
    resources = ["${var.source_bucket_arn}/*"]
  }

  statement {
    sid    = "ReplicateToDestination"
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags"
    ]
    resources = ["${var.destination_bucket_arn}/*"]
  }
}

resource "aws_iam_role" "replication" {
  name               = var.replication_role_name
  assume_role_policy = data.aws_iam_policy_document.replication_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "replication" {
  name   = "${var.replication_role_name}-policy"
  role   = aws_iam_role.replication.id
  policy = data.aws_iam_policy_document.replication_permissions.json
}

data "aws_iam_policy_document" "destination_bucket_policy" {
  statement {
    sid    = "AllowReplicationFromSource"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.replication.arn]
    }

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:GetObjectVersionTagging",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]

    resources = ["${var.destination_bucket_arn}/*"]
  }
}

resource "aws_s3_bucket_replication_configuration" "this" {
  depends_on = [
    aws_iam_role_policy.replication
  ]

  bucket = var.source_bucket_id
  role   = aws_iam_role.replication.arn

  dynamic "rule" {
    for_each = {
      for idx, r in var.replication_rules : idx => r
    }

    content {
      id       = rule.value.id
      priority = try(rule.value.priority, tonumber(rule.key) + 1)
      status   = rule.value.enable_replication ? "Enabled" : "Disabled"

      dynamic "filter" {
        for_each = try(rule.value.filter_prefix, null) == null || try(rule.value.filter_prefix, "") == "" ? [] : [rule.value.filter_prefix]

        content {
          prefix = filter.value
        }
      }

      delete_marker_replication {
        status = rule.value.enable_delete_marker_replication ? "Enabled" : "Disabled"
      }

      destination {
        bucket        = var.destination_bucket_arn
        storage_class = try(rule.value.destination_storage_class, "STANDARD")
        account       = var.destination_account_id

        dynamic "encryption_configuration" {
          for_each = try(rule.value.destination_kms_key_arn, null) == null ? [] : [rule.value.destination_kms_key_arn]

          content {
            replica_kms_key_id = encryption_configuration.value
          }
        }

        dynamic "access_control_translation" {
          for_each = try(rule.value.enable_bucket_owner_enforced, true) && var.destination_account_id != null ? [1] : []

          content {
            owner = "Destination"
          }
        }
      }
    }
  }
}
