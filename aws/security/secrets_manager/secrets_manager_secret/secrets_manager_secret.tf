resource "aws_secretsmanager_secret" "secretsmanager_secret" {
  # Required parameters for the Secrets Manager secret
  #region = var.secretmanager_secret_optional.region
  description                    = var.secretsmanager_secret_optional.description
  kms_key_id                     = var.secretsmanager_secret_optional.kms_key_id
  name_prefix                    = var.secretsmanager_secret_optional.name_prefix
  name                           = var.secretsmanager_secret_optional.name
  policy                         = var.secretsmanager_secret_optional.policy
  recovery_window_in_days        = var.secretsmanager_secret_optional.recovery_window_in_days
  force_overwrite_replica_secret = var.secretsmanager_secret_optional.force_overwrite_replica_secret
  tags                           = var.secretsmanager_secret_optional.tags

  dynamic "replica" {
    for_each = var.secretsmanager_secret_optional.replica != null ? [1] : []
    content {
      kms_key_id = var.secretsmanager_secret_optional.replica.kms_key_id #optional in block
      region     = var.secretsmanager_secret_optional.replica.region     #required in block
    }
  }
}
