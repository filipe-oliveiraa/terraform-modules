
# Terraform Modules by Filipe Oliveira

This repository contains a structured collection of reusable, production-grade Terraform modules, focused primarily on AWS.

The goal is to provide clean, versioned, and scalable infrastructure code with Terraform dynamic modular design, and best practices in infrastructure as code.



## About Me

My name is Filipe Oliveira. I build and maintain cloud-native systems with a focus on clarity, flexibility, and automation.  
This repository is both a practical toolkit and a portfolio of how I approach infrastructure engineering.

- GitHub: [github.com/filipe-oliveiraa](https://github.com/filipe-oliveiraa)
- LinkedIn: [linkedin.com/in/filipe-amaro-oliveira](https://www.linkedin.com/in/filipe-amaro-oliveira)

---

## Available Modules

| Path              | Description                      | Status         |
| ----------------- | -------------------------------- | -------------- |
| `aws/compute/ec2` | Configurable EC2 instance module | Stable         |

---

## Folder Structure

```

terraform-modules/
├── aws/
│   ├── compute/
│   │   └── ec2/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       ├── README.md
│   │       └── CHANGELOG.md
│   ├── network/
│   │   └── vpc/
│   │       ├── ...
├── README.md

````

---

## Design Philosophy

This monorepo is designed with the following principles in mind:

* **Reusability**: All modules are input-driven and general-purpose.
* **Modularity**: Logic is grouped cleanly with scoped responsibilities.
* **Optionality**: Default behavior is minimal; advanced features can be enabled when needed.
* **Dynamic Rendering**: Uses `dynamic` blocks to avoid unnecessary configuration.
* **Clarity**: Each module contains its own README and changelog.

---

## How to Use a Module

Each module can be consumed using Terraform’s built-in support for modules in Git repositories.

### Example: EC2 Module

```hcl
module "ec2" {
  source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/compute/ec2?ref=v1.0.0"

  ec2_instance_optional = {
    ami                         = "ami-0abcdef1234567890"
    instance_type               = "t3.micro"
    subnet_id                   = "subnet-12345678"
    associate_public_ip_address = true
    tags = {
      Name = "example-ec2"
    }
  }

  ec2_instance_optional_block = {
    metadata_options = {
      http_tokens                 = "required"
      http_endpoint               = "enabled"
      http_put_response_hop_limit = 2
    }
  }
}
````

---

## Versioning Strategy

This repository uses **semantic versioning** (`vMAJOR.MINOR.PATCH`) with Git tags that apply to the full repo.

Each module maintains a local `CHANGELOG.md` to describe its changes. When updating a module, the changelog should be updated and a new Git tag should be pushed.

### Releasing a New Version

```bash
git tag v1.2.0 -m "Add metadata options to EC2 module"
git push origin v1.2.0
```

### Example with Version Pinning

```hcl
source = "git::https://github.com/filipe-oliveiraa/terraform-modules.git//aws/compute/ec2?ref=v1.2.0"
```

---
