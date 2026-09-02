variable "security_group_optional" {
  description = "Optional parameters for the Security Group itself. Rules live in ingress_rules/egress_rules, not here."
  type = object({
    region                 = optional(string)
    description            = optional(string)
    name                   = optional(string)
    name_prefix            = optional(string)
    revoke_rules_on_delete = optional(bool)
    tags                   = optional(map(string))
    vpc_id                 = optional(string)
  })

  # Every attribute is optional, so an omitted object is a valid call.
  default = {}
}

variable "ingress_rules" {
  description = <<-EOT
    Inbound rules, keyed by a stable name of your choosing (the key becomes part
    of the Terraform address, so renaming a key replaces that rule).

    Each rule targets exactly ONE source: cidr_ipv4, cidr_ipv6, prefix_list_id
    or referenced_security_group_id. That is an AWS constraint on
    aws_vpc_security_group_ingress_rule, not a choice this module makes - the
    older inline-block form accepted lists and quietly expanded them into
    several rules.

    Omit from_port/to_port when ip_protocol is "-1" (all protocols).

    Example:
      ingress_rules = {
        https_from_vpc = {
          ip_protocol = "tcp"
          from_port   = 443
          to_port     = 443
          cidr_ipv4   = "10.0.0.0/16"
          description = "HTTPS from inside the VPC"
        }
      }
  EOT

  type = map(object({
    ip_protocol                  = string
    description                  = optional(string)
    from_port                    = optional(number)
    to_port                      = optional(number)
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string))
  }))

  default = {}

  validation {
    condition = alltrue([
      for k, r in var.ingress_rules :
      length(compact([
        r.cidr_ipv4,
        r.cidr_ipv6,
        r.prefix_list_id,
        r.referenced_security_group_id,
      ])) == 1
    ])
    error_message = "Each ingress rule must set exactly one of cidr_ipv4, cidr_ipv6, prefix_list_id or referenced_security_group_id. AWS rejects a rule with none or with several, and it only does so at apply time - this checks it at plan time instead."
  }
}

variable "egress_rules" {
  description = <<-EOT
    Outbound rules. Same shape and same one-source-per-rule constraint as
    ingress_rules.

    Note: a security group created by Terraform with no egress rule blocks all
    outbound traffic. The familiar "allow all egress" default only applies to
    groups created outside Terraform, so declare it explicitly if you want it:

      egress_rules = {
        all_out = {
          ip_protocol = "-1"
          cidr_ipv4   = "0.0.0.0/0"
        }
      }
  EOT

  type = map(object({
    ip_protocol                  = string
    description                  = optional(string)
    from_port                    = optional(number)
    to_port                      = optional(number)
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string))
  }))

  default = {}

  validation {
    condition = alltrue([
      for k, r in var.egress_rules :
      length(compact([
        r.cidr_ipv4,
        r.cidr_ipv6,
        r.prefix_list_id,
        r.referenced_security_group_id,
      ])) == 1
    ])
    error_message = "Each egress rule must set exactly one of cidr_ipv4, cidr_ipv6, prefix_list_id or referenced_security_group_id. AWS rejects a rule with none or with several, and it only does so at apply time - this checks it at plan time instead."
  }
}
