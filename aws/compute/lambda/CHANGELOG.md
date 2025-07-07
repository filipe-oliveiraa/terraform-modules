# Changelog — Lambda Module

All notable changes to this module will be documented here.

This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and [Semantic Versioning](https://semver.org/).

---

## [v1.0.0] - 2025-07-07

### Added
- Initial release of the Lambda function module
- Included `variables.tf`, `outputs.tf`, and `lambda.tf` with:
  - Optional and nested input structures for flexibility
  - Essential outputs covering function metadata, networking, and configuration
  - Use of `dynamic` blocks for conditional resource configuration
  - SnapStart configuration for published versions
  - Logging configuration with customizable log levels and formats
  - Image configuration for container-based Lambda functions
  - Ephemeral storage configuration with adjustable size
  - File system configuration for EFS integration
  - Environment variables support
  - VPC configuration with required subnet and security group IDs
  - Dead letter queue configuration for unprocessed events
  - Tracing configuration with support for "PassThrough" and "Active" modes

---

## [Unreleased]

### Added

### Changed

### Fixed