# aws_lambda_permission exports no attributes of its own beyond its id, but the
# id is worth surfacing: it is the statement id AWS actually stored, which is
# what you look for when reading the function's resource policy.
output "id" {
  description = "Statement ID of the Lambda permission."
  value       = aws_lambda_permission.lambda_permission.id
}
