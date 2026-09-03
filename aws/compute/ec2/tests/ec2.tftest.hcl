mock_provider "aws" {}

# Regression test. The module used to plan with no ami, no instance_type and no
# launch_template, and only fail at apply with the provider's own
# "one of ami,launch_template must be specified". A precondition now catches it
# at plan time.
run "no_ami_or_instance_type_and_no_launch_template_is_rejected_at_plan_time" {
  command = plan

  expect_failures = [
    aws_instance.ec2_instance,
  ]
}

run "imdsv2_is_required_by_default" {
  command = plan

  variables {
    ec2_instance_optional = { ami = "ami-0123456789abcdef0", instance_type = "t3.micro" }
  }

  # An instance answering IMDSv1 turns any SSRF into instance-role credential
  # theft. The module renders metadata_options unconditionally so this holds
  # even when the caller passes nothing.
  assert {
    condition     = aws_instance.ec2_instance.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 must be the default - http_tokens should be \"required\" when the caller sets no metadata_options."
  }
}

run "imdsv2_default_can_be_overridden" {
  command = plan

  variables {
    ec2_instance_optional       = { ami = "ami-0123456789abcdef0", instance_type = "t3.micro" }
    ec2_instance_optional_block = { metadata_options = { http_tokens = "optional" } }
  }

  # Secure by default, but not a cage: a caller with a reason can still opt out.
  assert {
    condition     = aws_instance.ec2_instance.metadata_options[0].http_tokens == "optional"
    error_message = "An explicit http_tokens value must win over the secure default."
  }
}

run "scalar_arguments_flow_through" {
  command = plan

  variables {
    ec2_instance_optional = {
      ami           = "ami-0123456789abcdef0"
      instance_type = "t3.micro"
      subnet_id     = "subnet-aaaa1111"
      monitoring    = true
      tags          = { Name = "app-1" }
    }
  }

  assert {
    condition     = aws_instance.ec2_instance.instance_type == "t3.micro"
    error_message = "instance_type must come from ec2_instance_optional."
  }

  assert {
    condition     = aws_instance.ec2_instance.ami == "ami-0123456789abcdef0"
    error_message = "ami must come from ec2_instance_optional."
  }

  assert {
    condition     = aws_instance.ec2_instance.tags["Name"] == "app-1"
    error_message = "tags must come from ec2_instance_optional."
  }
}

# associate_public_ip_address is deliberately not asserted here. It is
# Optional+Computed: when the caller leaves it unset the provider derives it
# from the subnet's map_public_ip_on_launch, so its value is unknown at plan
# and an assertion on it would only ever test the mock. The property that
# matters - this module never sets it on the caller's behalf - is visible in
# main.tf, where it is a plain pass-through of the input.

run "root_volume_is_encrypted_by_default" {
  command = plan

  variables {
    ec2_instance_optional = { ami = "ami-0123456789abcdef0", instance_type = "t3.micro" }
  }

  # The whole point of rendering root_block_device unconditionally: a caller who
  # passes no block at all still gets an encrypted root volume, instead of
  # inheriting whatever the AMI happens to carry.
  assert {
    condition     = aws_instance.ec2_instance.root_block_device[0].encrypted == true
    error_message = "A call with no root_block_device must still produce an encrypted root volume."
  }
}

run "explicit_encrypted_wins_over_the_default" {
  command = plan

  variables {
    ec2_instance_optional = { ami = "ami-0123456789abcdef0", instance_type = "t3.micro" }
    ec2_instance_optional_block = {
      root_block_device = { encrypted = false, volume_size = 20 }
    }
  }

  # Secure by default, not a cage - the same rule as the IMDSv2 default.
  assert {
    condition     = aws_instance.ec2_instance.root_block_device[0].encrypted == false
    error_message = "An explicit encrypted value inside root_block_device must win over encrypt_root_volume."
  }

  assert {
    condition     = aws_instance.ec2_instance.root_block_device[0].volume_size == 20
    error_message = "Other root_block_device settings must still flow through."
  }
}

run "encrypt_root_volume_false_opts_out_and_warns" {
  command = plan

  variables {
    ec2_instance_optional = { ami = "ami-0123456789abcdef0", instance_type = "t3.micro" }
    encrypt_root_volume   = false
  }

  assert {
    condition     = aws_instance.ec2_instance.root_block_device[0].encrypted == false
    error_message = "encrypt_root_volume = false must be honoured."
  }

  # Opting out is allowed, but it should never be silent.
  expect_failures = [
    check.root_volume_encryption,
  ]
}

run "nested_blocks_render_only_when_set" {
  command = plan

  variables {
    ec2_instance_optional = {
      ami           = "ami-0123456789abcdef0"
      instance_type = "t3.micro"
    }
    ec2_instance_optional_block = {
      root_block_device = {
        volume_size = 20
        encrypted   = true
      }
    }
  }

  assert {
    condition     = aws_instance.ec2_instance.root_block_device[0].volume_size == 20
    error_message = "root_block_device values must flow through."
  }

  # cpu_options is still conditional, so it is the honest test that omitted
  # blocks stay omitted - root_block_device is now always rendered.
  assert {
    condition     = length(aws_instance.ec2_instance.cpu_options) == 0
    error_message = "A block the caller did not set must not be rendered."
  }
}
