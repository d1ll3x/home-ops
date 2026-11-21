terraform {
  required_version = ">= 1.11.0"

  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.30.0"
    }
  }
}

# Credentials come from the environment only (mapped from fnox by `just terraform`):
# TAILSCALE_OAUTH_CLIENT_ID / TAILSCALE_OAUTH_CLIENT_SECRET, an OAuth client with
# the policy_file and dns scopes. The tailnet defaults to the client's own.
provider "tailscale" {}
