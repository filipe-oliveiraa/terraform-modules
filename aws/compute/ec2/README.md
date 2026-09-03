# EC2 Instance Module

Single EC2 instance with broad optionality exposed through two objects: `ec2_instance_optional` (top-level attributes) and `ec2_instance_optional_block` (nested/dynamic blocks for storage, metadata, etc.). Designed to mirror the AWS provider surface while keeping defaults minimal.

## Requirements / Assumptions
- Provide at least an AMI, instance type, and networking placement (`subnet_id` or `network_interface` block) that fits your VPC.
- Security groups can be supplied via `security_groups` or `vpc_security_group_ids`.
- User data and EBS settings are optional; defaults do not create extra devices.

## Inputs
- `ec2_instance_optional` (object): Core attributes like `ami`, `instance_type`, `subnet_id`, `associate_public_ip_address`, `key_name`, `iam_instance_profile`, `tags`, etc.
- `ec2_instance_optional_block` (object): Dynamic blocks such as `root_block_device`, `ebs_block_device`, `network_interface`, `metadata_options`, `cpu_options`, and more.

## Outputs
- `id`, `arn`, `availability_zone`, `primary_network_interface_id`
- `public_ip`, `public_dns`, `private_dns`
- `capacity_reservation_specification`, `tags_all`, `outpost_arn`, `password_data`

## Example
```hcl
module "ec2" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/compute/ec2?ref=ec2/v2.0.0"

  ec2_instance_optional = {
    ami                         = "ami-0abcdef1234567890"
    instance_type               = "t3.micro"
    subnet_id                   = "subnet-12345678"
    vpc_security_group_ids      = ["sg-abcdef1234567890"]
    associate_public_ip_address = true
    tags = { Name = "demo-ec2" }
  }

  ec2_instance_optional_block = {
    root_block_device = {
      volume_size = 16
      volume_type = "gp3"
      encrypted   = true
      tags        = { Name = "demo-ec2-root" }
    }
    metadata_options = {
      http_tokens                 = "required"
      http_put_response_hop_limit = 2
      http_endpoint               = "enabled"
    }
  }
}
```

## Behaviour worth knowing

**IMDSv2 is the default.** The module always renders a `metadata_options` block
and sets `http_tokens = "required"` unless you give it a value. An instance that
still answers IMDSv1 turns any SSRF in an app on the box into "read the instance
role's credentials", which is the most exploited EC2 misconfiguration there is.
Setting it is an in-place update, so this replaces nothing. To opt out:

```hcl
ec2_instance_optional_block = {
  metadata_options = { http_tokens = "optional" }
}
```

**The root volume is encrypted by default.** `root_block_device` is rendered
unconditionally with `encrypted = true`, so a call that passes no block at all
still gets an encrypted root volume rather than inheriting whatever the AMI
carries.

Precedence, most specific first:

1. `ec2_instance_optional_block.root_block_device.encrypted`
2. `encrypt_root_volume` (defaults to `true`)

Opting out is allowed and warns rather than blocking:

```hcl
encrypt_root_volume = false   # check block reports a warning; the plan proceeds
```

**Upgrading an existing instance to v2 replaces it.** The provider is explicit:
"modifying the `encrypted` or `kms_key_id` settings of the `root_block_device`
requires resource replacement". If you have instances created with v1 and no
`root_block_device`, `terraform plan` will show a replacement. Either accept it
in a maintenance window, or pin `encrypt_root_volume = false` to keep the old
behaviour and decide later.

**An AMI and an instance type are required at plan time.** `aws_instance` needs
both, or a `launch_template` that supplies them. The module checks this with a
precondition, so a call missing them fails at plan with a message naming the
module's inputs, instead of failing minutes into an apply with the provider's
`"one of ami,launch_template must be specified"`.
