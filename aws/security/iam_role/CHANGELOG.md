# Changelog — IAM Module

All notable changes to this module will be documented here.

This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and [Semantic Versioning](https://semver.org/).

---

## [v1.0.0] - 2025-07-07

### Added
- Initial release of the EC2 instance module
- Included `variables.tf`, `outputs.tf`, and `ec2.tf` with:
  - Optional and nested input structures for flexibility
  - Essential outputs covering instance metadata and networking
  - Use of `dynamic` blocks for conditional resource configuration
  - Lifecycle rule to ignore tag changes for smoother updates

---

## [Unreleased]

### Added

### Changed

### Fixed