resource "aws_security_group" "security_group" {
  # Optional top-level parameters
  #region                 = var.security_group_optional.region
  description            = var.security_group_optional.description
  name                   = var.security_group_optional.name
  name_prefix            = var.security_group_optional.name_prefix
  revoke_rules_on_delete = var.security_group_optional.revoke_rules_on_delete
  tags                   = var.security_group_optional.tags
  vpc_id                 = var.security_group_optional.vpc_id

  # Rules are deliberately NOT inline blocks here. Inline ingress/egress makes
  # this resource the sole owner of the group's entire rule set: anything that
  # adds a rule out of band (another module, a controller, a console edit) is
  # silently reverted on the next apply, and the diff never says why. The
  # separate rule resources below are individually addressable in state, so a
  # rule can be added, changed or removed on its own.
  lifecycle {
    create_before_destroy = true
  }
}

# One resource per rule, keyed by a caller-chosen name so removing a rule from
# the middle of the map does not re-index (and therefore recreate) the others -
# which is exactly what a list index would do.
resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.ingress_rules

  security_group_id = aws_security_group.security_group.id

  description = each.value.description
  ip_protocol = each.value.ip_protocol

  # Left null for ip_protocol = "-1" (all protocols), where ports are meaningless.
  from_port = each.value.from_port
  to_port   = each.value.to_port

  # Exactly one of these is set per rule - enforced by the variable validation.
  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id

  tags = each.value.tags
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = var.egress_rules

  security_group_id = aws_security_group.security_group.id

  description = each.value.description
  ip_protocol = each.value.ip_protocol

  from_port = each.value.from_port
  to_port   = each.value.to_port

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id

  tags = each.value.tags
}
