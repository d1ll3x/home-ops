terraform {
  required_providers {
    tailscale = {
      source = "tailscale/tailscale"
      # Lower bound only: the root providers.tf pins the exact version.
      version = ">= 0.30.0"
    }
  }
}
