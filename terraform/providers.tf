terraform {
  # use_lockfile (S3-native state locking) needs Terraform >= 1.11.
  required_version = ">= 1.11.0"

  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.30.0"
    }
  }

  # Partial configuration: settings in backend.hcl (terraform init -backend-config=backend.hcl),
  # credentials in AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY, mapped from fnox by `just terraform`.
  backend "s3" {}
}

# No credential variables: the provider reads TAILSCALE_OAUTH_CLIENT_ID /
# TAILSCALE_OAUTH_CLIENT_SECRET from the environment (mapped from fnox by
# `just terraform`); an OAuth client with the policy_file and dns scopes.
# The tailnet defaults to the client's own.
provider "tailscale" {}
