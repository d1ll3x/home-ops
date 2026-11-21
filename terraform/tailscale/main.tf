module "tailscale" {
  source = "../modules/tailscale"

  policy = file("${path.module}/policy.hujson")

  split_dns = {
    "tebbenet.nl" = ["192.168.20.1"] # UniFi gateway, reached over the odysseus subnet route
  }
}

# Both objects already exist in the tailnet (set by hand in the admin console).
# Importing adopts them instead of blindly overwriting; once applied these
# blocks are no-ops and can be deleted.
import {
  to = module.tailscale.tailscale_acl.this
  id = "acl"
}

import {
  to = module.tailscale.tailscale_dns_split_nameservers.this["tebbenet.nl"]
  id = "tebbenet.nl"
}
