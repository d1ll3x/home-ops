variable "policy" {
  description = "Tailnet policy file contents (HuJSON or JSON). Replaces the whole policy file."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.policy)) > 0
    error_message = "policy must not be empty: an empty policy file would lock every device out."
  }
}

variable "split_dns" {
  description = "Split DNS: domain => nameserver IPs that resolve it for tailnet clients."
  type        = map(list(string))
  default     = {}
  nullable    = false

  validation {
    condition     = alltrue([for ns in values(var.split_dns) : length(ns) > 0])
    error_message = "every split_dns domain needs at least one nameserver."
  }
}
