variable "function_name" {
  description = "The name of the Lambda function."
  type        = string
}

variable "role" {
  description = "The ARN of the IAM role that Lambda assumes when it executes the function."
  type        = string
}

variable "lambda_function_optional" {
  description = "Optional parameters for the Lambda function."
  type = object({
    architectures                      = optional(list(string)) #e.g. ["x86_64", "arm64"]
    code_signing_config_arn            = optional(string)       # ARN of the code signing configuration
    description                        = optional(string)       # Description of the Lambda function
    filename                           = optional(string)       # Path to the deployment package
    handler                            = optional(string)       #Function entry point in your code. Required if package_type is Zip
    image_uri                          = optional(string)       # URI of the container image
    kms_key_arn                        = optional(string)       # ARN of the KMS key for encryption of the function's environment variables. If not specified, the default AWS Lambda key is used.
    layers                             = optional(list(string)) # List of layer ARNs to attach to the function
    memory_size                        = optional(number)       # Memory size in MB allocated to the function. Default is 128 MB. Valid values are between 128 and 10240 MB, in increments of 1 MB.
    package_type                       = optional(string)       # Type of deployment package. Valid values are Zip and Image. Default is Zip.
    publish                            = optional(bool)         # Whether to publish a new version of the function when updating it. Default is false.
    replace_security_groups_on_destroy = optional(bool)         # Whether to replace security groups on destroy. Default is false. 
    replacement_security_group_ids     = optional(list(string)) # List of security group IDs to replace on destroy. Required if replace_security_groups_on_destroy is true.
    reserved_concurrent_executions     = optional(number)       # The number of concurrent executions to reserve for the function. Default is unreserved.
    runtime                            = optional(string)       # Runtime environment for the Lambda function. Required if package_type is Zip. Valid values are nodejs, python, java, etc.
    s3_bucket                          = optional(string)       # Name of the S3 bucket containing the deployment package. Conflicts with filename, image_uri. One of these must be specified.
    s3_key                             = optional(string)       # S3 key of an object containing the deployment package. Required if s3_bucket is specified.
    s3_object_version                  = optional(string)       # Version of the S3 object containing the deployment package. Optional. Conflicts with filename, image_uri.
    skip_destroy                       = optional(bool)         #Whether to retain the old version of a previously deployed Lambda Layer. Default is false.
    source_code_hash                   = optional(string)       # Base64-encoded SHA256 hash of the deployment package. Required if package_type is Zip.
    tags                               = optional(map(string))  # Map of tags to assign to the Lambda function. Tags are a set of key-value pairs that can be used to categorize and manage resources.
    timeout                            = optional(number)       # Maximum time in seconds that the function can run before it is terminated. Default is 3 seconds. Valid values are between 1 and 900 seconds.

    snap_start = optional(object({ # SnapStart configuration for Lambda functions
      apply_on = string            # Valid values are "PublishedVersions"
    }))

    logging_config = optional(object({
      log_format            = string           # Format of the log messages. Valid values are "json" or "text".
      application_log_level = optional(string) # Log level for application logs. Valid values are "TRACE" "DEBUG", "INFO", "WARN", "ERROR", "FATAL".
      log_group             = optional(string) # Name of the CloudWatch log group for the function's logs.
      system_log_level      = optional(string) # Log level for system logs. Valid values are "DEBUG", "INFO", "WARN".
    }))

    image_config = optional(object({
      command           = optional(list(string)) # Parameters to pass to the container image.
      entry_point       = optional(list(string)) # Entry point for the application.
      working_directory = optional(string)       # Working directory for the container image.
    }))

    ephemeral_storage = optional(object({ # Ephemeral storage configuration for the Lambda function
      size = number                       # Size in MB of the ephemeral storage(/tmp). Valid values are between 512 and 10240 MB.
    }))

    file_system_config = optional(object({ # File system configuration for the Lambda function
      arn              = string            # ARN of the EFS file system
      local_mount_path = string            # Local mount path in the Lambda function. Must start with /mnt/
    }))

    environment = optional(object({     # Environment variables for the Lambda function
      variables = optional(map(string)) # Map of environment variables to set for the function
    }))

    vpc_config = optional(object({                 # VPC configuration for the Lambda function
      security_group_ids          = list(string)   # List of security group IDs associated with the Lambda function
      subnet_ids                  = list(string)   # List of subnet IDs associated with the Lambda function
      ipv6_allowed_for_dual_stack = optional(bool) # Whether to allow outbound IPv6 traffic on VPC functions connected to dual-stack VPCs. Default is false.
    }))

    dead_letter_config = optional(object({ # Dead letter queue configuration for the Lambda function
      target_arn = string                  # ARN of the SQS queue or SNS topic to which Lambda sends events that could not be processed
    }))

    tracing_config = optional(object({ # Tracing configuration for the Lambda function
      mode = string                    # Tracing mode. Valid values are "PassThrough" or "Active".
    }))
  })
}