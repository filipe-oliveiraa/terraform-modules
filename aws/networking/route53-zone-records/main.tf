locals {
  # Keyed by what actually identifies a record to Route 53 - name, type, and
  # set_identifier when routing policies make several records share a name and
  # type. The list position is deliberately NOT part of the key: it used to be,
  # which meant deleting one record from the middle of var.records re-keyed
  # every record after it, and Terraform answered by destroying and recreating
  # them. For DNS that is a short outage of records nobody touched.
  record_map = {
    for record in var.records :
    join("_", compact([record.name, record.type, try(record.set_identifier, null)])) => record
  }

  invalid_records = [
    for record in var.records :
    record
    if(
      (
        try(record.alias, null) == null &&
        length(coalesce(try(record.records, []), [])) == 0
      )
      ||
      (
        try(record.alias, null) != null &&
        length(coalesce(try(record.records, []), [])) > 0
      )
    )
  ]
}

resource "aws_route53_zone" "this" {
  name              = var.zone_name
  comment           = try(var.route53_zone_optional.comment, null)
  force_destroy     = try(var.route53_zone_optional.force_destroy, false)
  delegation_set_id = try(var.route53_zone_optional.delegation_set_id, null)
  tags              = var.tags

  dynamic "vpc" {
    for_each = var.vpc_associations

    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = try(vpc.value.vpc_region, null)
    }
  }
}

resource "aws_route53_record" "this" {
  for_each = local.record_map

  zone_id         = aws_route53_zone.this.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = try(each.value.alias, null) == null ? each.value.ttl : null
  records         = try(each.value.alias, null) == null ? each.value.records : null
  set_identifier  = try(each.value.set_identifier, null)
  health_check_id = try(each.value.health_check_id, null)
  allow_overwrite = try(each.value.allow_overwrite, false)

  dynamic "alias" {
    for_each = try(each.value.alias, null) == null ? [] : [each.value.alias]

    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = try(alias.value.evaluate_target_health, false)
    }
  }

  lifecycle {
    precondition {
      condition     = length(local.invalid_records) == 0
      error_message = "Every record must specify either an alias target or at least one record value, but not both."
    }
  }
}
