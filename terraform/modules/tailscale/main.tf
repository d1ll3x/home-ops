# The whole tailnet policy file: grants, tests, tagOwners, autoApprovers.
# The provider validates it (including "tests") against the Tailscale API at plan time.
resource "tailscale_acl" "this" {
  acl = var.policy
}

# One restricted nameserver set per domain. Global nameservers, MagicDNS and
# search paths are not managed here and stay as set in the admin console.
resource "tailscale_dns_split_nameservers" "this" {
  for_each = var.split_dns

  domain      = each.key
  nameservers = each.value
}
