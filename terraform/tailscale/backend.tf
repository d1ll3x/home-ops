# Partial configuration: settings live in backend.hcl, credentials in the
# environment (AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY, mapped from fnox).
# terraform init -backend-config=backend.hcl
terraform {
  backend "s3" {}
}
