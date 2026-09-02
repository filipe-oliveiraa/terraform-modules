mock_provider "aws" {}

variables {
  zone_name = "internal.example.com"
}

run "zone_name_reaches_the_resource" {
  command = plan

  assert {
    condition     = aws_route53_zone.this.name == "internal.example.com"
    error_message = "zone_name must be passed through unmodified."
  }
}

run "no_records_by_default" {
  command = plan

  assert {
    condition     = length(aws_route53_record.this) == 0
    error_message = "An empty records list must create no records."
  }
}

run "records_are_keyed_by_identity_not_list_position" {
  command = plan

  variables {
    records = [
      { name = "app.internal.example.com", type = "A", records = ["10.0.0.10"] },
      { name = "db.internal.example.com", type = "A", records = ["10.0.0.20"] },
      { name = "app.internal.example.com", type = "TXT", records = ["\"v=spf1 -all\""] },
    ]
  }

  # The keys must be derived from name/type (and set_identifier), never from
  # the index. Deleting the first record must not re-key the other two, because
  # for DNS a re-key means destroy and recreate - a real, if brief, outage.
  assert {
    condition     = contains(keys(aws_route53_record.this), "app.internal.example.com_A")
    error_message = "Record keys must be name_type, with no list index in them."
  }

  assert {
    condition     = contains(keys(aws_route53_record.this), "app.internal.example.com_TXT")
    error_message = "Same name with a different type must be a distinct key."
  }

  assert {
    condition     = length(aws_route53_record.this) == 3
    error_message = "Three distinct records must produce three resources."
  }
}

run "set_identifier_disambiguates_same_name_and_type" {
  command = plan

  variables {
    records = [
      { name = "api.internal.example.com", type = "A", records = ["10.0.0.10"], set_identifier = "blue" },
      { name = "api.internal.example.com", type = "A", records = ["10.0.0.11"], set_identifier = "green" },
    ]
  }

  # Weighted/latency routing legitimately repeats name+type, so set_identifier
  # has to be part of the key or the two would collide into one.
  assert {
    condition     = length(aws_route53_record.this) == 2
    error_message = "Records sharing name and type must stay distinct via set_identifier."
  }

  assert {
    condition     = contains(keys(aws_route53_record.this), "api.internal.example.com_A_blue")
    error_message = "set_identifier must be part of the key."
  }
}

run "record_values_flow_through" {
  command = plan

  variables {
    records = [
      { name = "app.internal.example.com", type = "A", ttl = 60, records = ["10.0.0.10"] },
    ]
  }

  assert {
    condition     = aws_route53_record.this["app.internal.example.com_A"].ttl == 60
    error_message = "ttl must come from the record definition."
  }

  assert {
    condition     = contains(aws_route53_record.this["app.internal.example.com_A"].records, "10.0.0.10")
    error_message = "records must come from the record definition."
  }
}
