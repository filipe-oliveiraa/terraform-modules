# The attachment exports no attributes of its own beyond its id. It is exposed
# so callers can order dependent resources against the attachment itself rather
# than against the role, which exists before the policy is attached.
output "id" {
  description = "ID of the role/policy attachment."
  value       = aws_iam_role_policy_attachment.iam_role_policy_attachment.id
}
