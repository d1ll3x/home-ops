output "split_dns" {
  description = "Split DNS domains and their nameservers as applied."
  value       = { for domain, ns in tailscale_dns_split_nameservers.this : domain => ns.nameservers }
}
