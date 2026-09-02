mock_provider "aws" {}

run "callable_with_no_inputs" {
  command = plan

  assert {
    condition     = length(aws_secretsmanager_secret.secretsmanager_secret.replica) == 0
    error_message = "No replica input must produce no replica block."
  }
}

run "name_and_kms_key_flow_through" {
  command = plan

  variables {
    secretsmanager_secret_optional = {
      name        = "/app/dev/db-password"
      description = "Application database password"
      kms_key_id  = "alias/app-secrets"
    }
  }

  assert {
    condition     = aws_secretsmanager_secret.secretsmanager_secret.name == "/app/dev/db-password"
    error_message = "name must come from secretsmanager_secret_optional."
  }

  assert {
    condition     = aws_secretsmanager_secret.secretsmanager_secret.kms_key_id == "alias/app-secrets"
    error_message = "kms_key_id must come from secretsmanager_secret_optional."
  }
}

run "replica_block_renders_when_set" {
  command = plan

  variables {
    secretsmanager_secret_optional = {
      name = "/app/dev/db-password"
      replica = {
        region = "eu-central-1"
      }
    }
  }

  assert {
    condition     = length(aws_secretsmanager_secret.secretsmanager_secret.replica) == 1
    error_message = "Setting replica must render exactly one replica block."
  }
}

# This module creates the secret container and never its value. The input that
# looked like it set the value (secret_string) was declared but wired to
# nothing, so a caller setting it got silence. It has been removed rather than
# wired up, because aws_secretsmanager_secret_version would put the plaintext
# in state permanently. There is no assertion to make here - the guarantee is
# that the resource does not exist in this module at all.
