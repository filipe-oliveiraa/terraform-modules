variable "ec2_instance_optional" {
  type = object({
    region                               = optional(string)
    ami                                  = optional(string)
    associate_public_ip_address          = optional(bool)
    availability_zone                    = optional(string)
    disable_api_stop                     = optional(bool)
    disable_api_termination              = optional(bool)
    ebs_optimized                        = optional(bool)
    enable_primary_ipv6                  = optional(bool)
    get_password_data                    = optional(bool)
    hibernation                          = optional(bool)
    host_id                              = optional(string)
    host_resource_group_arn              = optional(string)
    iam_instance_profile                 = optional(string)
    instance_initiated_shutdown_behavior = optional(string)
    instance_market_options              = optional(any)
    instance_type                        = optional(string)
    ipv6_address_count                   = optional(number)
    ipv6_addresses                       = optional(list(string))
    key_name                             = optional(string)
    monitoring                           = optional(bool)
    placement_group                      = optional(string)
    placement_partition_number           = optional(number)
    private_ip                           = optional(string)
    secondary_private_ips                = optional(list(string))
    security_groups                      = optional(list(string))
    source_dest_check                    = optional(bool)
    subnet_id                            = optional(string)
    tags                                 = optional(map(string))
    tenancy                              = optional(string)
    user_data                            = optional(string)
    user_data_base64                     = optional(string)
    user_data_replace_on_change          = optional(bool)
    volume_tags                          = optional(map(string))
    vpc_security_group_ids               = optional(list(string))
  })
}
 
variable "ec2_instance_optional_block" {
  type = object({
    capacity_reservation_specification = optional(object({
      capacity_reservation_preference = optional(string)
      capacity_reservation_target = optional(list(object({
        capacity_reservation_id                 = optional(string)
        capacity_reservation_resource_group_arn = optional(string)
      })))
    }))
    cpu_options = optional(object({
      amd_sev_snp      = optional(bool)
      core_count       = optional(number)
      threads_per_core = optional(number)
    }))
    credit_specification = optional(object({
      cpu_credits = optional(string)
    }))
    ebs_block_device = optional(list(object({
      device_name           = string
      delete_on_termination = optional(bool)
      encrypted             = optional(bool)
      iops                  = optional(number)
      kms_key_id            = optional(string)
      snapshot_id           = optional(string)
      tags                  = optional(map(string))
      throughput            = optional(number)
      volume_size           = optional(number)
      volume_type           = optional(string)
    })))
    enclave_options = optional(object({
      enabled = optional(bool)
    }))
    ephemeral_block_device = optional(list(object({
      device_name  = string
      no_device    = optional(string)
      virtual_name = optional(string)
    })))
    launch_template = optional(object({
      id      = optional(string)
      name    = optional(string)
      version = optional(string)
    }))
    maintenance_options = optional(object({
      auto_recovery = optional(string)
    }))
    metadata_options = optional(object({
      http_endpoint               = optional(string)
      http_protocol_ipv6          = optional(string)
      http_put_response_hop_limit = optional(number)
      http_tokens                 = optional(string)
      instance_metadata_tags      = optional(string)
    }))
    network_interface = optional(list(object({
      network_interface_id  = string
      device_index          = number
      network_card_index    = optional(number)
      delete_on_termination = optional(bool)
    })))
    private_dns_name_options = optional(object({
      enable_resource_name_dns_a_record    = optional(bool)
      enable_resource_name_dns_aaaa_record = optional(bool)
      hostname_type                        = optional(string)
    }))
    root_block_device = optional(object({
      delete_on_termination = optional(bool)
      encrypted             = optional(bool)
      iops                  = optional(number)
      kms_key_id            = optional(string)
      tags                  = optional(map(string))
      throughput            = optional(number)
      volume_size           = optional(number)
      volume_type           = optional(string)
    }))
  })
}
 