resource "aws_security_group" "security_group" {
  # Optional top-level parameters
  #region                 = var.security_group_optional.region
  description            = var.security_group_optional.description
  name                   = var.security_group_optional.name
  name_prefix            = var.security_group_optional.name_prefix
  revoke_rules_on_delete = var.security_group_optional.revoke_rules_on_delete
  tags                   = var.security_group_optional.tags
  vpc_id                 = var.security_group_optional.vpc_id

  # Ingress rules
  dynamic "ingress" {
    for_each = var.security_group_optional.ingress != null ? var.security_group_optional.ingress : []
    content {
      from_port        = ingress.value.from_port # required
      to_port          = ingress.value.to_port   # required
      protocol         = ingress.value.protocol  # required
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null)
      description      = lookup(ingress.value, "description", null)
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", null)
      prefix_list_ids  = lookup(ingress.value, "prefix_list_ids", null)
      security_groups  = lookup(ingress.value, "security_groups", null)
      self             = lookup(ingress.value, "self", null)
    }
  }

  # Egress rules
  dynamic "egress" {
    for_each = var.security_group_optional.egress != null ? var.security_group_optional.egress : []
    content {
      from_port        = egress.value.from_port # required
      to_port          = egress.value.to_port   # required
      protocol         = egress.value.protocol  # required
      cidr_blocks      = lookup(egress.value, "cidr_blocks", null)
      description      = lookup(egress.value, "description", null)
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", null)
      prefix_list_ids  = lookup(egress.value, "prefix_list_ids", null)
      security_groups  = lookup(egress.value, "security_groups", null)
      self             = lookup(egress.value, "self", null)
    }
  }
}
