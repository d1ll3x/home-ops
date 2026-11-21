set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

# Credentials are read from env vars that fnox exports (run under `fnox exec`, or
# with them loaded in the shell) and mapped to the names Terraform expects.
[private]
tf *args:
    AWS_ACCESS_KEY_ID="${SCW_ACCESS_KEY:?not set: run under fnox exec}" \
    AWS_SECRET_ACCESS_KEY="${SCW_SECRET_KEY:?not set: run under fnox exec}" \
    TAILSCALE_OAUTH_CLIENT_ID="${TS_OAUTH_CLIENT_ID:?not set: run under fnox exec}" \
    TAILSCALE_OAUTH_CLIENT_SECRET="${TS_OAUTH_CLIENT_SECRET:?not set: run under fnox exec}" \
      terraform -chdir="{{ source_directory() }}" {{ args }}

[doc('Initialise against the S3 state backend')]
init *args:
    just terraform tf init -backend-config=backend.hcl {{ args }}

[doc('Plan (never applies)')]
plan *args:
    just terraform tf plan {{ args }}

[doc('Format all Terraform code')]
fmt *args:
    terraform fmt -recursive {{ args }} "{{ source_directory() }}"

[doc('Validate and lint (no credentials or backend needed)')]
validate:
    terraform -chdir="{{ source_directory() }}" init -backend=false -input=false > /dev/null
    terraform -chdir="{{ source_directory() }}" validate
    tflint --chdir="{{ source_directory() }}" --recursive --config="{{ source_directory() }}/.tflint.hcl"
