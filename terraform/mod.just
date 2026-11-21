set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

# Credentials are read from env vars that fnox exports (run under `fnox exec`, or
# with them loaded in the shell) and mapped to the names Terraform expects.
[private]
tf stack *args:
    AWS_ACCESS_KEY_ID="${SCW_ACCESS_KEY:?not set: run under fnox exec}" \
    AWS_SECRET_ACCESS_KEY="${SCW_SECRET_KEY:?not set: run under fnox exec}" \
    TAILSCALE_OAUTH_CLIENT_ID="${TS_OAUTH_CLIENT_ID:?not set: run under fnox exec}" \
    TAILSCALE_OAUTH_CLIENT_SECRET="${TS_OAUTH_CLIENT_SECRET:?not set: run under fnox exec}" \
      terraform -chdir="{{ source_directory() }}/{{ stack }}" {{ args }}

[doc('Initialise a stack against its S3 state backend')]
init stack="tailscale" *args:
    just terraform tf "{{ stack }}" init -backend-config=backend.hcl {{ args }}

[doc('Plan a stack (never applies)')]
plan stack="tailscale" *args:
    just terraform tf "{{ stack }}" plan {{ args }}

[doc('Format all Terraform code')]
fmt *args:
    terraform fmt -recursive {{ args }} "{{ source_directory() }}"

[doc('Validate and lint a stack (no credentials or backend needed)')]
validate stack="tailscale":
    terraform -chdir="{{ source_directory() }}/{{ stack }}" init -backend=false -input=false > /dev/null
    terraform -chdir="{{ source_directory() }}/{{ stack }}" validate
    tflint --chdir="{{ source_directory() }}/{{ stack }}" --config="{{ source_directory() }}/.tflint.hcl"
