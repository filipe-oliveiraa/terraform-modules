# This module creates the secret CONTAINER only, never its value.
#
# There used to be a secret_string attribute here. It was declared and never
# read by any resource, so a caller who set it got no error, no value stored in
# Secrets Manager, and the secret still sitting in the plan output and the state
# file. Wiring it up was the wrong fix: aws_secretsmanager_secret_version puts
# the plaintext in state permanently, where anyone with read access to the
# backend can retrieve it.
#
# Put the value in out of band instead - once, at creation:
#   aws secretsmanager put-secret-value --secret-id <name> --secret-string ...
# and let whatever consumes it read it at runtime.
variable "secretsmanager_secret_optional" {
  description = "Optional parameters for the Secrets Manager secret. The secret's value is deliberately not settable here - see the comment above."
  type = object({
    name                           = optional(string)
    name_prefix                    = optional(string)
    description                    = optional(string)
    kms_key_id                     = optional(string)
    policy                         = optional(string)
    recovery_window_in_days        = optional(number)
    force_overwrite_replica_secret = optional(bool)
    tags                           = optional(map(string))
    replica = optional(object({
      region     = string
      kms_key_id = optional(string)
    }))
  })

  # Every attribute is optional, so an omitted object is a valid call.
  default = {}
}
