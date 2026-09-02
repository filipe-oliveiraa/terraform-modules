terraform {
  # Floors, not pins: a library module states the minimum it needs and lets the
  # root module choose the exact version. Pinning here (~> 6.x) would force that
  # choice on every consumer.
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}
