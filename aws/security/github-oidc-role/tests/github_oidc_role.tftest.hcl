mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  role_name        = "github-deploy"
  allowed_subjects = ["repo:my-org/my-repo:ref:refs/heads/main"]
}

run "role_is_named_as_asked" {
  command = plan

  assert {
    condition     = aws_iam_role.github_oidc_role.name == "github-deploy"
    error_message = "role_name must be passed through unmodified."
  }
}

run "oidc_provider_is_created_by_default" {
  command = plan

  assert {
    condition     = length(aws_iam_openid_connect_provider.this) == 1
    error_message = "With create_oidc_provider defaulting to true, the provider must be created."
  }
}

run "existing_provider_can_be_reused" {
  command = plan

  variables {
    create_oidc_provider       = false
    existing_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
  }

  # An account can only have one OIDC provider per issuer URL, so a second role
  # in the same account has to reuse the first one rather than create its own.
  assert {
    condition     = length(aws_iam_openid_connect_provider.this) == 0
    error_message = "create_oidc_provider = false must not create a provider."
  }
}

run "trust_is_scoped_to_the_given_subjects" {
  command = plan

  # This is the security property of the whole module: without a sub condition,
  # any GitHub Actions workflow in any repository on github.com could assume
  # this role. The subjects must reach the trust policy.
  assert {
    condition = anytrue([
      for s in data.aws_iam_policy_document.assume_role.statement :
      anytrue([
        for c in s.condition :
        c.variable == "token.actions.githubusercontent.com:sub" &&
        contains(c.values, "repo:my-org/my-repo:ref:refs/heads/main")
      ])
    ])
    error_message = "allowed_subjects must become a sub condition on the trust policy - without it any repository could assume the role."
  }
}

run "audience_is_constrained" {
  command = plan

  assert {
    condition = anytrue([
      for s in data.aws_iam_policy_document.assume_role.statement :
      anytrue([
        for c in s.condition :
        c.variable == "token.actions.githubusercontent.com:aud"
      ])
    ])
    error_message = "The trust policy must constrain the aud claim as well as sub."
  }
}
