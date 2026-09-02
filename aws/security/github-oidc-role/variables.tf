variable "role_name" {
  description = "Name of the IAM role to be assumed via GitHub OIDC."
  type        = string
}

variable "role_path" {
  description = "Path for the IAM role."
  type        = string
  default     = "/"
}

variable "role_description" {
  description = "Description for the IAM role."
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds for the role."
  type        = number
  default     = 3600
}

variable "tags" {
  description = "Tags to apply to the IAM role and (optionally) the OIDC provider."
  type        = map(string)
  default     = {}
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the role."
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Inline policies to attach to the role."
  type        = map(string)
  default     = {}
}

variable "oidc_provider_url" {
  description = "OIDC provider URL. For GitHub use https://token.actions.githubusercontent.com"
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "oidc_thumbprints" {
  description = "Thumbprints for the OIDC provider. Default includes the GitHub Actions thumbprint."
  type        = list(string)
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

variable "oidc_client_ids" {
  description = "Client IDs (audience) allowed. GitHub recommends sts.amazonaws.com."
  type        = list(string)
  default     = ["sts.amazonaws.com"]
}

variable "create_oidc_provider" {
  description = "Whether to create the OIDC provider. Set to false to use an existing one."
  type        = bool
  default     = true
}

variable "existing_oidc_provider_arn" {
  description = "Existing OIDC provider ARN to use when create_oidc_provider is false."
  type        = string
  default     = null
}

variable "allowed_subjects" {
  description = "List of allowed sub claims (e.g., repo:org/repo:ref:refs/heads/main)."
  type        = list(string)
}

variable "audience" {
  description = "Audience to match on the token. GitHub uses sts.amazonaws.com."
  type        = string
  default     = "sts.amazonaws.com"
}
