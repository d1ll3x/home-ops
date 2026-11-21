terraform {
  required_version = ">= 1.11.0"

  required_providers {
    tailscale = {
      source = "tailscale/tailscale"
      # Lower bound only: the root config that calls this module pins the exact version.
      version = ">= 0.30.0"
    }
  }
}
