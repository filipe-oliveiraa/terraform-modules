resource "aws_lambda_function" "lambda_function" {
  # Required parameters
  function_name = var.function_name
  role          = var.role

  # Optional parameters
  architectures = var.lambda_function_optional.architectures
  code_signing_config_arn = var.lambda_function_optional.code_signing_config_arn
  description   = var.lambda_function_optional.description
  filename = var.lambda_function_optional.filename
  handler       = var.lambda_function_optional.handler
  image_uri = var.lambda_function_optional.image_uri
  kms_key_arn   = var.lambda_function_optional.kms_key_arn
  layers        = var.lambda_function_optional.layers
  memory_size   = var.lambda_function_optional.memory_size
  package_type = var.lambda_function_optional.package_type
  publish       = var.lambda_function_optional.publish
  #region       = var.lambda_function_optional.region
  replace_security_groups_on_destroy = var.lambda_function_optional.replace_security_groups_on_destroy
  replacement_security_group_ids = var.lambda_function_optional.replacement_security_group_ids
  reserved_concurrent_executions = var.lambda_function_optional.reserved_concurrent_executions
  runtime       = var.lambda_function_optional.runtime
  s3_bucket = var.lambda_function_optional.s3_bucket
  s3_key    = var.lambda_function_optional.s3_key
  s3_object_version = var.lambda_function_optional.s3_object_version
  skip_destroy = var.lambda_function_optional.skip_destroy
  source_code_hash = var.lambda_function_optional.source_code_hash
  tags        = var.lambda_function_optional.tags
  timeout      = var.lambda_function_optional.timeout




  dynamic snap_start {
    for_each = var.lambda_function_optional.snap_start != null ? [1] : []
    content {
      apply_on = var.lambda_function_optional.snap_start.apply_on #required in block
    }
  }

  dynamic  logging_config {
    for_each = var.lambda_function_optional.logging_config != null ? [1] : []
    content {
      log_format = var.lambda_function_optional.logging_config.log_format #required in block
      application_log_level = var.lambda_function_optional.logging_config.application_log_level #optional in block
      log_group = var.lambda_function_optional.logging_config.log_group #optional in block
      system_log_level = var.lambda_function_optional.logging_config.system_log_level #optional in block
    }

  }

 dynamic image_config {
    for_each = var.lambda_function_optional.image_config != null ? [1] : []
    content {
      command = var.lambda_function_optional.image_config.command #optional in block
      entry_point = var.lambda_function_optional.image_config.entry_point #optional in block
      working_directory = var.lambda_function_optional.image_config.working_directory #optional in block
    }
    
  }


   dynamic ephemeral_storage {
    for_each = var.lambda_function_optional.ephemeral_storage != null ? [1] : []
    content {
      size = var.lambda_function_optional.ephemeral_storage.size #required in block
    }
    
  }

  dynamic file_system_config {
    for_each = var.lambda_function_optional.file_system_config != null ? [1] : []
    content {
      arn = var.lambda_function_optional.file_system_config.arn #required in block
      local_mount_path = var.lambda_function_optional.file_system_config.local_mount_path #required in block
    }
    
  }

  dynamic "environment" {
    for_each = var.lambda_function_optional.environment != null ? [1] : []
    content {
      variables = var.lambda_function_optional.environment.variables #optional in block
    }
  }

  dynamic "vpc_config" {
    for_each = var.lambda_function_optional.vpc_config != null ? [1] : []
    content {
      subnet_ids         = var.lambda_function_optional.vpc_config.subnet_ids #required in block
      security_group_ids = var.lambda_function_optional.vpc_config.security_group_ids #required in block
      ipv6_allowed_for_dual_stack = var.lambda_function_optional.vpc_config.ipv6_allowed_for_dual_stack #optional in block
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.lambda_function_optional.dead_letter_config != null ? [1] : []
    content {
      target_arn = var.lambda_function_optional.dead_letter_config.target_arn #required in block
    }
  }

  dynamic "tracing_config" {
    for_each = var.lambda_function_optional.tracing_config != null ? [1] : []
    content {
      mode = var.lambda_function_optional.tracing_config.mode #required in block
    }
  }
}