# Security Group Module

Creates a security group with dynamic ingress/egress blocks so you can declare any rule set without clutter. Ideal for quickly standing up VPC ingress/egress controls.

## Requirements / Assumptions
- Provide a `vpc_id` unless you rely on the provider default VPC.
- Ingress/egress items require `from_port`, `to_port`, and `protocol`; CIDRs or SG references are optional per rule.

## Inputs
- `security_group_optional` (object): `vpc_id`, `name`/`name_prefix`, `description`, `revoke_rules_on_delete`, `tags`, plus `ingress` and `egress` lists with rule objects (`from_port`, `to_port`, `protocol`, optional cidr/security group fields).

## Outputs
- `id`, `arn`, `owner_id`, `tags_all`

## Example
```hcl
module "security_group" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/networking/Simple/security_group?ref=v1.0.0"

  security_group_optional = {
    vpc_id = aws_vpc.main.id
    name   = "app-sg"
    ingress = [
      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
    ]
    egress = [
      { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
    ]
    tags = { Name = "app-sg" }
  }
}
```
