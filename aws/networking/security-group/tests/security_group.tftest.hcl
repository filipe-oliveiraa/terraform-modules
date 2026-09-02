mock_provider "aws" {}

variables {
  security_group_optional = {
    name        = "app-sg"
    description = "Application security group"
    vpc_id      = "vpc-aaaa1111"
  }
}

run "group_attributes_flow_through" {
  command = plan

  assert {
    condition     = aws_security_group.security_group.vpc_id == "vpc-aaaa1111"
    error_message = "vpc_id must come from security_group_optional."
  }

  assert {
    condition     = aws_security_group.security_group.name == "app-sg"
    error_message = "name must come from security_group_optional."
  }
}

run "no_rules_by_default" {
  command = plan

  # A group with no rules denies everything, which is the safe default. What
  # matters is that the module does not invent rules the caller did not ask for.
  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.this) == 0
    error_message = "No ingress_rules input must create no ingress rules."
  }

  assert {
    condition     = length(aws_vpc_security_group_egress_rule.this) == 0
    error_message = "No egress_rules input must create no egress rules."
  }
}

run "rules_are_keyed_by_name_not_index" {
  command = plan

  variables {
    ingress_rules = {
      https_from_vpc = {
        ip_protocol = "tcp"
        from_port   = 443
        to_port     = 443
        cidr_ipv4   = "10.0.0.0/16"
        description = "HTTPS from inside the VPC"
      }
      ssh_from_bastion = {
        ip_protocol                  = "tcp"
        from_port                    = 22
        to_port                      = 22
        referenced_security_group_id = "sg-bastion1"
      }
    }
    egress_rules = {
      all_out = {
        ip_protocol = "-1"
        cidr_ipv4   = "0.0.0.0/0"
      }
    }
  }

  # The map key is the resource address. This is the whole reason rules are a
  # map and not a list: removing one rule must not re-index the others.
  assert {
    condition     = aws_vpc_security_group_ingress_rule.this["https_from_vpc"].from_port == 443
    error_message = "Rules must be addressable by their map key."
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.this["ssh_from_bastion"].referenced_security_group_id == "sg-bastion1"
    error_message = "A rule sourced from another security group must pass referenced_security_group_id through."
  }

  assert {
    condition     = aws_vpc_security_group_egress_rule.this["all_out"].ip_protocol == "-1"
    error_message = "ip_protocol must be passed through unmodified."
  }
}

run "every_rule_is_bound_to_this_group" {
  # apply, not plan: the group's id is computed, so the comparison cannot be
  # resolved until the (mocked) resource exists.
  command = apply

  variables {
    ingress_rules = {
      https = { ip_protocol = "tcp", from_port = 443, to_port = 443, cidr_ipv4 = "10.0.0.0/16" }
    }
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.this["https"].security_group_id == aws_security_group.security_group.id
    error_message = "Rules must attach to the group this module creates."
  }
}

# The provider only rejects a rule with no source at apply time. The variable
# validation pulls that failure forward to plan.
run "rule_with_no_source_is_rejected_at_plan_time" {
  command = plan

  variables {
    ingress_rules = {
      broken = { ip_protocol = "tcp", from_port = 443, to_port = 443 }
    }
  }

  expect_failures = [
    var.ingress_rules,
  ]
}

run "rule_with_two_sources_is_rejected_at_plan_time" {
  command = plan

  variables {
    egress_rules = {
      broken = {
        ip_protocol = "-1"
        cidr_ipv4   = "0.0.0.0/0"
        cidr_ipv6   = "::/0"
      }
    }
  }

  expect_failures = [
    var.egress_rules,
  ]
}
