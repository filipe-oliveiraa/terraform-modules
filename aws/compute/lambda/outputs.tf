output "arn" {
  description = "The ARN of the Lambda function."
  value       = aws_lambda_function.lambda_function.arn
}

output "code_sha256" {
  description = "Base64-encoded representation of raw SHA-256 sum of the zip file."
  value       = aws_lambda_function.lambda_function.code_sha256
}

output "invoke_arn" {
  description = "The ARN to be used for invoking the Lambda function from API Gateway - to be used in aws_api_gateway_integration's uri."
  value       = aws_lambda_function.lambda_function.invoke_arn
}

output "last_modified" {
  description = "The date that the function was last updated."
  value       = aws_lambda_function.lambda_function.last_modified
}

output "qualified_arn" {
  description = " ARN identifying your Lambda Function Version (if versioning is enabled via publish = true)."
  value       = aws_lambda_function.lambda_function.qualified_arn
}

output "qualified_invoke_arn" {
  description = "Qualified ARN (ARN with lambda version number) to be used for invoking Lambda Function from API Gateway - to be used in aws_api_gateway_integration's uri."
  value       = aws_lambda_function.lambda_function.qualified_invoke_arn
}

output "signing_job_arn" {
  description = "ARN of the signing job."
  value       = aws_lambda_function.lambda_function.signing_job_arn
}

output "signing_profile_version_arn" {
  description = "ARN of the signing profile version."
  value       = aws_lambda_function.lambda_function.signing_profile_version_arn
}

output "snap_start_optimization_status" {
  description = "Optimization status of the SnapStart configuration for the Lambda function. Valid values are 'On' and 'Off'."
  value       = aws_lambda_function.lambda_function.snap_start != null ? aws_lambda_function.lambda_function.snap_start[0].optimization_status : null
}

output "source_code_size" {
  description = " Size in bytes of the function .zip file."
  value       = aws_lambda_function.lambda_function.source_code_size
}

output "tags_all" {
  description = " Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_lambda_function.lambda_function.tags_all
}

output "version" {
  description = "Latest published version of your Lambda Function."
  value       = aws_lambda_function.lambda_function.version
}

output "vpc_id" {
  description = "ID of the VPC associated with the Lambda function."
  value       = aws_lambda_function.lambda_function.vpc_config != null ? aws_lambda_function.lambda_function.vpc_config.vpc_id : null
}
  