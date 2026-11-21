# Bundled terraform ruleset; no plugins to download.
config {
  call_module_type = "local"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# House style: modules declare only required_providers; the root providers.tf
# sets required_version for the whole configuration.
rule "terraform_required_version" {
  enabled = false
}
