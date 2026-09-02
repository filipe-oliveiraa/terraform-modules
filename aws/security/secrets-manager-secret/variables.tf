variable "secretsmanager_secret_optional" {
  description = "Optional parameters for the Secrets Manager secret."
  type = object({
    name                           = optional(string)
    name_prefix                    = optional(string)
    description                    = optional(string)
    secret_string                  = optional(string)
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
}
