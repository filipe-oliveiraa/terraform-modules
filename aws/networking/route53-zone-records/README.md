# Route 53 Zone & Records Module

Creates a Route 53 hosted zone (public or private) and a set of DNS records (standard or alias). Designed to mirror the AWS provider `aws_route53_zone` and `aws_route53_record` resources.

## Requirements / Assumptions
- For public zones, you must update your registrar to use the name servers output by this module (`name_servers`).
- For private zones, supply VPC associations.

## Inputs
- `zone_name` (string, required): FQDN for the hosted zone.
- `route53_zone_optional` (object, default `{}`):
  - `comment` (string)
  - `force_destroy` (bool, default `false`)
  - `delegation_set_id` (string)
- `tags` (map(string), default `{}`): Tags for the zone.
- `vpc_associations` (list(object), default `[]`): Private zone associations `{vpc_id, vpc_region?}`.
- `records` (list(object), default `[]`): DNS records to create. Each record supports:
  - `name` (string), `type` (string)
  - `ttl` (number, default `300`) — ignored for alias
  - `records` (list(string)) — required for non-alias
  - `alias` (object, optional): `{name, zone_id, evaluate_target_health?}`
  - `set_identifier` (string, optional)
  - `health_check_id` (string, optional)
  - `allow_overwrite` (bool, default `false`)

## Outputs
- `zone_id`, `zone_arn`, `zone_name`, `name_servers`
- `record_fqdns`: Map of record identifiers to FQDNs

## Usage: Public zone + alias to CloudFront
```hcl
module "route53" {
  source = "../../modules/route53_record"

  zone_name = "example.com"

  records = [
    {
      name    = "www.example.com"
      type    = "A"
      alias = {
        name                   = module.cloudfront.domain_name
        zone_id                = module.cloudfront.hosted_zone_id
        evaluate_target_health = false
      }
      allow_overwrite = true
    }
  ]
}
# After apply, update registrar to use module.route53.name_servers
```

## Usage: Private zone with VPC associations
```hcl
module "route53_private" {
  source   = "../../modules/route53_record"
  zone_name = "internal.example.com"

  vpc_associations = [
    { vpc_id = aws_vpc.main.id, vpc_region = "us-east-1" }
  ]

  records = [
    {
      name    = "api.internal.example.com"
      type    = "A"
      ttl     = 60
      records = ["10.0.0.10"]
    }
  ]
}
```

## Notes
- Each record must specify either `records` **or** `alias`, not both (the module enforces this).
- For public zones, registrar NS changes are required for DNS to propagate.
