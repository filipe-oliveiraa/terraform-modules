variable "security_group_optional" {
  description = "Optional parameters for the Security Group."
  type = object({
    region                 = optional(string)
    description            = optional(string)
    name                   = optional(string)
    name_prefix            = optional(string)
    revoke_rules_on_delete = optional(bool)
    tags                   = optional(map(string))
    vpc_id                 = optional(string)

    ingress = optional(list(object({
      from_port        = number # required
      to_port          = number # required
      protocol         = string # required
      cidr_blocks      = optional(list(string))
      description      = optional(string)
      ipv6_cidr_blocks = optional(list(string))
      prefix_list_ids  = optional(list(string))
      security_groups  = optional(list(string))
      self             = optional(bool)
    })))

    egress = optional(list(object({
      from_port        = number # required
      to_port          = number # required
      protocol         = string # required
      cidr_blocks      = optional(list(string))
      description      = optional(string)
      ipv6_cidr_blocks = optional(list(string))
      prefix_list_ids  = optional(list(string))
      security_groups  = optional(list(string))
      self             = optional(bool)
    })))
  })

}
