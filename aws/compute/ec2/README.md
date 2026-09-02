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
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/compute/Simple/ec2?ref=v1.0.0"

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
