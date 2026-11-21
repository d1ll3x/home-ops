# The whole tailnet policy file: grants, tests, tagOwners, autoApprovers.
# The provider validates it (including "tests") against the Tailscale API at plan time.
resource "tailscale_acl" "this" {
  acl = var.policy

  # Greenfield: Terraform takes the policy over instead of importing it. Without
  # this, create sends If-Match "ts-default" and fails with 412 on any tailnet
  # whose policy was ever edited.
  overwrite_existing_content = true
}

# One restricted nameserver set per domain. Create is an upsert (PATCH of that
# domain), so an existing entry is simply overwritten; no import needed.
# Global nameservers, MagicDNS and search paths are not managed here.
resource "tailscale_dns_split_nameservers" "this" {
  for_each = var.split_dns

  domain      = each.key
  nameservers = each.value
}
