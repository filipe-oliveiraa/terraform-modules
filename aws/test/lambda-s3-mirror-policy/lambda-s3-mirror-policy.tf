locals {
  # Normalize prefixes: strip trailing /* or /, then append /*
  norm_source_list_prefixes = [
    for p in var.source_list_prefixes : "${trim(p, "/*")}/*"
  ]
  norm_source_object_prefixes = [
    for p in var.source_object_prefixes : "${trim(p, "/*")}/*"
  ]
  norm_dest_prefixes = [
    for p in var.dest_prefixes : "${trim(p, "/*")}/*"
  ]

  source_object_arns = [
    for p in local.norm_source_object_prefixes :
    "arn:aws:s3:::${var.source_bucket}/${p}"
  ]
  dest_object_arns = [
    for p in local.norm_dest_prefixes :
    "arn:aws:s3:::${var.dest_bucket}/${p}"
  ]

  policy_document = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid      = "SourceList"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::${var.source_bucket}"
        Condition = {
          StringLike = {
            "s3:prefix" = local.norm_source_list_prefixes
          }
        }
      },
      {
        Sid      = "SourceRead"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:HeadObject"]
        Resource = local.source_object_arns
      },
      {
        Sid      = "DestList"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::${var.dest_bucket}"
        Condition = {
          StringLike = {
            "s3:prefix" = local.norm_dest_prefixes
          }
        }
      },
      {
        Sid    = "DestObjectOps"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:HeadObject",
          "s3:PutObject",
          "s3:CopyObject",
          "s3:DeleteObject",
          "s3:PutObjectTagging"
        ]
        Resource = local.dest_object_arns
      }
    ]
  })
}

resource "aws_iam_policy" "policy" {
  # Keep your original shape: we just feed the rendered JSON here
  policy = local.policy_document

  # Optional fields preserved exactly like your module
  description = var.iam_policy_optional.description
  name_prefix = var.iam_policy_optional.name_prefix
  name        = var.iam_policy_optional.name
  path        = var.iam_policy_optional.path
  tags        = var.iam_policy_optional.tags
}
