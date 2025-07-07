resource "aws_instance" "ec2_instance" {
 
  # region                               = var.ec2_instance_optional.region
  ami                         = var.ec2_instance_optional.ami
  associate_public_ip_address = var.ec2_instance_optional.associate_public_ip_address
  availability_zone           = var.ec2_instance_optional.availability_zone
  disable_api_stop            = var.ec2_instance_optional.disable_api_stop
  disable_api_termination     = var.ec2_instance_optional.disable_api_termination
  ebs_optimized               = var.ec2_instance_optional.ebs_optimized
  # enable_primary_ipv6                  = var.ec2_instance_optional.enable_primary_ipv6
  get_password_data                    = var.ec2_instance_optional.get_password_data
  hibernation                          = var.ec2_instance_optional.hibernation
  host_id                              = var.ec2_instance_optional.host_id
  host_resource_group_arn              = var.ec2_instance_optional.host_resource_group_arn
  iam_instance_profile                 = var.ec2_instance_optional.iam_instance_profile
  instance_initiated_shutdown_behavior = var.ec2_instance_optional.instance_initiated_shutdown_behavior
  # instance_market_options              = var.ec2_instance_optional.instance_market_options
  instance_type               = var.ec2_instance_optional.instance_type
  ipv6_address_count          = var.ec2_instance_optional.ipv6_address_count
  ipv6_addresses              = var.ec2_instance_optional.ipv6_addresses
  key_name                    = var.ec2_instance_optional.key_name
  monitoring                  = var.ec2_instance_optional.monitoring
  placement_group             = var.ec2_instance_optional.placement_group
  placement_partition_number  = var.ec2_instance_optional.placement_partition_number
  private_ip                  = var.ec2_instance_optional.private_ip
  secondary_private_ips       = var.ec2_instance_optional.secondary_private_ips
  security_groups             = var.ec2_instance_optional.security_groups
  source_dest_check           = var.ec2_instance_optional.source_dest_check
  subnet_id                   = var.ec2_instance_optional.subnet_id
  tags                        = var.ec2_instance_optional.tags
  tenancy                     = var.ec2_instance_optional.tenancy
  user_data                   = var.ec2_instance_optional.user_data
  user_data_base64            = var.ec2_instance_optional.user_data_base64
  user_data_replace_on_change = var.ec2_instance_optional.user_data_replace_on_change
  volume_tags                 = var.ec2_instance_optional.volume_tags
  vpc_security_group_ids      = var.ec2_instance_optional.vpc_security_group_ids
 
  dynamic "capacity_reservation_specification" {
    for_each = var.ec2_instance_optional_block.capacity_reservation_specification != null ? [1] : []
    content {
      capacity_reservation_preference = var.ec2_instance_optional_block.capacity_reservation_specification.capacity_reservation_preference
      dynamic "capacity_reservation_target" {
        for_each = capacity_reservation_specification.value.capacity_reservation_target
        content {
          capacity_reservation_id                 = capacity_reservation_target.value.capacity_reservation_id
          capacity_reservation_resource_group_arn = capacity_reservation_target.value.capacity_reservation_resource_group_arn
        }
      }
    }
  }
 
  dynamic "cpu_options" {
    for_each = var.ec2_instance_optional_block.cpu_options != null ? [1] : []
    content {
      amd_sev_snp      = var.ec2_instance_optional_block.cpu_options.amd_sev_snp
      core_count       = var.ec2_instance_optional_block.cpu_options.core_count
      threads_per_core = var.ec2_instance_optional_block.cpu_options.threads_per_core
    }
  }
 
  dynamic "credit_specification" {
    for_each = var.ec2_instance_optional_block.credit_specification != null ? [1] : []
    content {
      cpu_credits = var.ec2_instance_optional_block.credit_specification.cpu_credits
    }
  }
 
  dynamic "ebs_block_device" {
    for_each = var.ec2_instance_optional_block.ebs_block_device != null ? var.ec2_instance_optional_block.ebs_block_device : []
    content {
      device_name           = ebs_block_device.value.device_name
      delete_on_termination = ebs_block_device.value.delete_on_termination
      encrypted             = ebs_block_device.value.encrypted
      iops                  = ebs_block_device.value.iops
      kms_key_id            = ebs_block_device.value.kms_key_id
      snapshot_id           = ebs_block_device.value.snapshot_id
      tags                  = ebs_block_device.value.tags
      throughput            = ebs_block_device.value.throughput
      volume_size           = ebs_block_device.value.volume_size
      volume_type           = ebs_block_device.value.volume_type
    }
  }
 
  dynamic "enclave_options" {
    for_each = var.ec2_instance_optional_block.enclave_options != null ? [1] : []
    content {
      enabled = var.ec2_instance_optional_block.enclave_options.enabled
    }
  }
  dynamic "ephemeral_block_device" {
    for_each = var.ec2_instance_optional_block.ephemeral_block_device != null ? var.ec2_instance_optional_block.ephemeral_block_device : []
    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = ephemeral_block_device.value.no_device
      virtual_name = ephemeral_block_device.value.virtual_name
    }
  }
 
  dynamic "launch_template" {
    for_each = var.ec2_instance_optional_block.launch_template != null ? [1] : []
    content {
      id      = var.ec2_instance_optional_block.launch_template.id
      name    = var.ec2_instance_optional_block.launch_template.name
      version = var.ec2_instance_optional_block.launch_template.version
    }
  }
 
  dynamic "maintenance_options" {
    for_each = var.ec2_instance_optional_block.maintenance_options != null ? [1] : []
    content {
      auto_recovery = var.ec2_instance_optional_block.maintenance_options.auto_recovery
    }
  }
 
  dynamic "metadata_options" {
    for_each = var.ec2_instance_optional_block.metadata_options != null ? [1] : []
    content {
      http_endpoint = var.ec2_instance_optional_block.metadata_options.http_endpoint
      # http_protocol_ipv6          = var.ec2_instance_optional_block.metadata_options.http_protocol_ipv6
      http_put_response_hop_limit = var.ec2_instance_optional_block.metadata_options.http_put_response_hop_limit
      http_tokens                 = var.ec2_instance_optional_block.metadata_options.http_tokens
      instance_metadata_tags      = var.ec2_instance_optional_block.metadata_options.instance_metadata_tags
    }
  }
 
  dynamic "network_interface" {
    for_each = var.ec2_instance_optional_block.network_interface != null ? var.ec2_instance_optional_block.network_interface : []
 
    content {
      network_interface_id  = network_interface.value.network_interface_id
      device_index          = network_interface.value.device_index
      network_card_index    = network_interface.value.network_card_index
      delete_on_termination = network_interface.value.delete_on_termination
    }
  }
 
  dynamic "private_dns_name_options" {
    for_each = var.ec2_instance_optional_block.private_dns_name_options != null ? [1] : []
    content {
      enable_resource_name_dns_a_record    = var.ec2_instance_optional_block.private_dns_name_options.enable_resource_name_dns_a_record
      enable_resource_name_dns_aaaa_record = var.ec2_instance_optional_block.private_dns_name_options.enable_resource_name_dns_aaaa_record
      hostname_type                        = var.ec2_instance_optional_block.private_dns_name_options.hostname_type
    }
  }
 
  dynamic "root_block_device" {
 
    for_each = var.ec2_instance_optional_block.root_block_device != null ? [1] : []
    content {
      delete_on_termination = var.ec2_instance_optional_block.root_block_device.delete_on_termination
      encrypted             = var.ec2_instance_optional_block.root_block_device.encrypted
      iops                  = var.ec2_instance_optional_block.root_block_device.iops
      kms_key_id            = var.ec2_instance_optional_block.root_block_device.kms_key_id
      tags                  = var.ec2_instance_optional_block.root_block_device.tags
      throughput            = var.ec2_instance_optional_block.root_block_device.throughput
      volume_size           = var.ec2_instance_optional_block.root_block_device.volume_size
      volume_type           = var.ec2_instance_optional_block.root_block_device.volume_type
    }
  }
 
  lifecycle {
    ignore_changes = [tags]
  }
}