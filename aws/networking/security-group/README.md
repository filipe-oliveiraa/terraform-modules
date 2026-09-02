# Security Group Module

Creates a security group plus its rules, each rule as its own resource.

## Why rules are separate resources

Inline `ingress`/`egress` blocks make `aws_security_group` the sole owner of the
group's entire rule set. Anything that adds a rule out of band - another module,
a controller, someone in the console - is reverted on the next apply, and the
diff does not explain why. `aws_vpc_security_group_ingress_rule` and
`aws_vpc_security_group_egress_rule` are individually addressable in state, so a
rule can be added, changed or removed on its own.

Rules are **maps keyed by a name you choose**, not lists. A list index is not a
stable identity: remove one rule from the middle and every rule after it is
re-keyed, which Terraform carries out as destroy-and-recreate.

## Requirements / Assumptions

- Provide `vpc_id` unless you rely on the provider's default VPC.
- Each rule sets **exactly one** source: `cidr_ipv4`, `cidr_ipv6`,
  `prefix_list_id` or `referenced_security_group_id`. That is an AWS constraint
  on the rule resources; it is checked here at plan time by a variable
  validation rather than left to fail during apply.
- Omit `from_port`/`to_port` when `ip_protocol` is `"-1"`.
- A group created by Terraform with no egress rule **blocks all outbound
  traffic**. The familiar "allow all egress" default only applies to groups
  created outside Terraform, so declare it if you want it.

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `security_group_optional` | object | `{}` | The group itself: `vpc_id`, `name`/`name_prefix`, `description`, `revoke_rules_on_delete`, `tags`. |
| `ingress_rules` | map(object) | `{}` | Inbound rules, keyed by name. |
| `egress_rules` | map(object) | `{}` | Outbound rules, same shape. |

Rule object: `ip_protocol` (required), `description`, `from_port`, `to_port`,
`cidr_ipv4`, `cidr_ipv6`, `prefix_list_id`, `referenced_security_group_id`,
`tags`.

## Outputs

`id`, `arn`, `owner_id`, `tags_all`, plus `ingress_rule_ids` and
`egress_rule_ids`, keyed by the same keys you used on the inputs.

## Example

```hcl
module "security_group" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/networking/security-group?ref=security-group/v2.0.0"

  security_group_optional = {
    vpc_id      = aws_vpc.main.id
    name        = "app-sg"
    description = "Application security group"
    tags        = { Name = "app-sg" }
  }

  ingress_rules = {
    https_from_vpc = {
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_ipv4   = aws_vpc.main.cidr_block
      description = "HTTPS from inside the VPC"
    }
    ssh_from_bastion = {
      ip_protocol                  = "tcp"
      from_port                    = 22
      to_port                      = 22
      referenced_security_group_id = module.bastion_sg.id
    }
  }

  egress_rules = {
    all_out = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}
```

## Migrating from v1

v1 took rules as lists inside `security_group_optional`:

```hcl
# v1
security_group_optional = {
  vpc_id  = aws_vpc.main.id
  ingress = [{ from_port = 443, to_port = 443, protocol = "tcp",
               cidr_blocks = ["10.0.0.0/16", "10.1.0.0/16"] }]
}

# v2
security_group_optional = { vpc_id = aws_vpc.main.id }
ingress_rules = {
  https_a = { ip_protocol = "tcp", from_port = 443, to_port = 443, cidr_ipv4 = "10.0.0.0/16" }
  https_b = { ip_protocol = "tcp", from_port = 443, to_port = 443, cidr_ipv4 = "10.1.0.0/16" }
}
```

Note the renames (`protocol` becomes `ip_protocol`, `cidr_blocks` becomes
`cidr_ipv4`) and that **a rule listing several CIDRs becomes one entry per
CIDR** - the rule resources take a single source each.

The rules change resource type, so the first apply replaces them. The group
itself is not replaced, and it now carries `create_before_destroy` so a
replacement never leaves dependents momentarily unattached.
