variable "action" {
  description = "The AWS Lambda action you want to allow (e.g., lambda:InvokeFunction)."
  type        = string
}

variable "function_name" {
  description = "The name (or ARN) of the Lambda function to which you are granting permissions."
  type        = string
}

variable "principal" {
  description = "The principal who is getting this permission. e.g., s3.amazonaws.com, events.amazonaws.com"
  type        = string
}

variable "lambda_permission_optional" {
  description = "Optional parameters for the Lambda permission."
  type = object({
    event_source_token     = optional(string)
    function_url_auth_type = optional(string)
    principal_org_id       = optional(string)
    qualifier              = optional(string)
    #region               = optional(string) # Uncomment if you want to expose region as a variable
    source_account      = optional(string)
    source_arn          = optional(string)
    statement_id        = optional(string)
    statement_id_prefix = optional(string)
  })
  #default = {} - Prefer not to define default. Don't forget to explicitly define as empty object in the module call.
}

