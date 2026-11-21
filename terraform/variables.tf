variable "tailscale_split_dns" {
  description = "Split DNS for tailnet clients: domain => nameserver IPs."
  type        = map(list(string))
  default = {
    "tebbenet.nl" = ["192.168.20.1"] # UniFi gateway, reached over the odysseus subnet route
  }
}
