# Scaleway Object Storage (S3-compatible), project home-ops. The bucket exists
# already (versioning on) and is not managed by Terraform.
# Never add credentials here: Terraform caches backend config in plaintext under .terraform/.
bucket       = "tebbenet-tfstate"
key          = "tailscale/terraform.tfstate"
region       = "nl-ams"
endpoints    = { s3 = "https://s3.nl-ams.scw.cloud" }
use_lockfile = true # S3 conditional writes (If-None-Match), supported by Scaleway Object Storage

# Scaleway is not AWS: skip the AWS-only STS/IAM/region/metadata calls.
skip_credentials_validation = true
skip_region_validation      = true
skip_requesting_account_id  = true
skip_metadata_api_check     = true
