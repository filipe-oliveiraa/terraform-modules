## GitHub OIDC IAM Role Module - https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html#idp_oidc_Create_GitHub

Creates an IAM role trusted by GitHub Actions OIDC and, optionally, the GitHub OIDC provider itself.

### Requirements
- Use this in the AWS account that GitHub will assume into.
- For CloudFront/Lambda usage, attach appropriate managed policies or inline policies to the role.
- If you already have the GitHub OIDC provider in the account, set `create_oidc_provider = false` and pass `existing_oidc_provider_arn`.

### Inputs
- `role_name` (string, required): Name of the IAM role.
- `role_path` (string, default `/`): Role path.
- `role_description` (string, default `null`).
- `max_session_duration` (number, default `3600`).
- `tags` (map(string), default `{}`).
- `managed_policy_arns` (list(string), default `[]`): Managed policies to attach. Supply at least one managed or inline policy to grant permissions.
- `inline_policies` (map(string), default `{}`): Inline policies (map of name => policy JSON).
- `oidc_provider_url` (string, default `https://token.actions.githubusercontent.com`).
- `oidc_thumbprints` (list(string), default GitHub thumbprint).
- `oidc_client_ids` (list(string), default `["sts.amazonaws.com"]`).
- `create_oidc_provider` (bool, default `true`): Create the OIDC provider.
- `existing_oidc_provider_arn` (string, default `null`): Use when not creating the provider.
- `allowed_subjects` (list(string), required): Allowed `sub` claims, e.g. `repo:Org/Repo:ref:refs/heads/main`.
- `audience` (string, default `sts.amazonaws.com`): Audience to match.

### Outputs
- `role_arn`, `role_name`, `oidc_provider_arn`

### Trust policy
Built from the GitHub doc example:
- Principal: Federated OIDC provider ARN
- Action: `sts:AssumeRoleWithWebIdentity`
- Conditions:
  - `token.actions.githubusercontent.com:aud = audience`
  - `token.actions.githubusercontent.com:sub` matches any value in `allowed_subjects`
  - Common patterns for `allowed_subjects`:
    - `repo:GitHubOrg/GitHubRepo:ref:refs/heads/main` — a single branch
    - `repo:GitHubOrg/GitHubRepo:ref:refs/heads/*` — any branch in a repo
    - `repo:GitHubOrg/GitHubRepo:*` — any ref (branches/tags/PR refs) in a repo
    - `repo:GitHubOrg/*` — any repo in an org (very broad; use with caution)

### Quick start (create provider + role, minimal permissions)
```hcl
module "github_oidc_role" {
  source = "../../modules/github_oicd_auth_role"

  role_name        = "github-oidc-deploy"
  allowed_subjects = ["repo:my-org/my-repo:ref:refs/heads/main"] # single branch

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/PowerUserAccess" # replace with least privilege
  ]
}
```

### Example (create provider + role for a branch with inline policy)
```hcl
module "github_oidc_role" {
  source = "../../modules/github_oicd_auth_role"

  role_name        = "github-oidc-deploy"
  allowed_subjects = ["repo:my-org/my-repo:ref:refs/heads/main"]

  managed_policy_arns = []
  inline_policies = {
    terraform_permissions = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["iam:PassRole", "iam:GetRole", "iam:ListRoles"]
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    Project = "github-oidc"
    Env     = "dev"
  }
}
```

### Example (reuse existing provider, multiple branches)
```hcl
module "github_oidc_role" {
  source = "../../modules/github_oicd_auth_role"

  role_name                 = "github-oidc-deploy"
  create_oidc_provider      = false
  existing_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"

  allowed_subjects = [
    "repo:my-org/my-repo:ref:refs/heads/*", # any branch in this repo
    "repo:my-org/another-repo:*"            # any ref in another repo
    # "repo:my-org/*"                      # any repo in org (broad; use with caution)
  ]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
}
```

### Reusing an existing GitHub OIDC provider (avoid EntityAlreadyExists)
If your account already has an OIDC provider for `https://token.actions.githubusercontent.com`, do not create a new one:
```hcl
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

module "github_oidc_role" {
  source = "../../modules/github_oicd_auth_role"

  role_name        = "github-oidc-deploy"
  allowed_subjects = ["repo:my-org/my-repo:ref:refs/heads/*"]

  create_oidc_provider       = false
  existing_oidc_provider_arn = data.aws_iam_openid_connect_provider.github.arn

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/PowerUserAccess"
  ]
}
```
This prevents `EntityAlreadyExists` when the provider URL is already present in the account.***

### Copy-paste patterns for `allowed_subjects`

**Single branch (main):**
```hcl
allowed_subjects = ["repo:my-org/my-repo:ref:refs/heads/main"]
```

**Any branch in one repo:**
```hcl
allowed_subjects = ["repo:my-org/my-repo:ref:refs/heads/*"]
```

**Any ref (branches/tags/PR) in one repo:**
```hcl
allowed_subjects = ["repo:my-org/my-repo:*"]
```

**Any repo in an org (broad, use with caution):**
```hcl
allowed_subjects = ["repo:my-org/*"]
```

### Full module examples by scope

**Single branch example**
```hcl
module "github_oidc_role" {
  source = "../../modules/github_oicd_auth_role"

  role_name        = "github-oidc-deploy"
  allowed_subjects = ["repo:my-org/my-repo:ref:refs/heads/main"]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/PowerUserAccess" # replace with least privilege
  ]
}
```

**Any branch in a repo**
```hcl
module "github_oidc_role" {
  source = "../../modules/github_oicd_auth_role"

  role_name        = "github-oidc-deploy"
  allowed_subjects = ["repo:my-org/my-repo:ref:refs/heads/*"]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/PowerUserAccess"
  ]
}
```

**Any ref in a repo (branches/tags/PR refs)**
```hcl
module "github_oidc_role" {
  source = "../../modules/github_oicd_auth_role"

  role_name        = "github-oidc-deploy"
  allowed_subjects = ["repo:my-org/my-repo:*"]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/PowerUserAccess"
  ]
}
```

**Any repo in an org (broad — use with caution)**
```hcl
module "github_oidc_role" {
  source = "../../modules/github_oicd_auth_role"

  role_name        = "github-oidc-deploy"
  allowed_subjects = ["repo:my-org/*"]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/PowerUserAccess"
  ]
}
```
