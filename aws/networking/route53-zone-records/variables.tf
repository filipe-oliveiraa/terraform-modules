variable "zone_name" {
  description = "Fully qualified domain name for the Route 53 hosted zone."
  type        = string
}

variable "route53_zone_optional" {
  description = "Optional settings for the hosted zone."
  type = object({
    comment           = optional(string)
    force_destroy     = optional(bool, false)
    delegation_set_id = optional(string)
  })
  default = {}
}

variable "tags" {
  description = "Tags to apply to the hosted zone."
  type        = map(string)
  default     = {}
}

variable "vpc_associations" {
  description = "VPC associations for private hosted zones."
  type = list(object({
    vpc_id     = string
    vpc_region = optional(string)
  }))
  default = []
}

variable "records" {
  description = "DNS records to create inside the hosted zone."
  type = list(object({
    name            = string
    type            = string
    ttl             = optional(number, 300)
    records         = optional(list(string))
    set_identifier  = optional(string)
    health_check_id = optional(string)
    allow_overwrite = optional(bool, false)
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, false)
    }))
  }))
  default = []
}
