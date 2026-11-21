module "tailscale" {
  source = "./modules/tailscale"

  policy    = file("${path.module}/policy.hujson")
  split_dns = var.tailscale_split_dns
}
