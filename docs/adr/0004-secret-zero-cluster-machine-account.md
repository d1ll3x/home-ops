# ADR-0004: Secret zero is a cluster-only machine account on a separate BWS project

External Secrets Operator authenticates with its own Bitwarden SM machine account, **`ESO`**. That account can read only the BWS project **`kubernetes/apps`**, which holds the in-cluster secrets (`cloudflare-api-token`, `technitium-tsig-key`). The Talos PKI stays in BWS project `kubernetes/talos`, readable only by `mandalore` (the workstation). The `base` stage of `just bootstrap cluster` delivers the token before ESO is installed: `kustomize build kubernetes/bootstrap/kustomize` → `fnox exec` → minijinja → `kubectl apply --server-side`. This is the same shape as home-ops' `kustomize build | op inject | kubectl apply`.

## Consequences
- A leaked in-cluster token can't reach the Talos PKI.
- `mandalore` also needs read access on `kubernetes/apps`, and `fnox.toml` needs a second `bitwarden-sm` provider (`apps`) for that project.
- The token is never in git. It exists as a Kubernetes Secret only after bootstrap.

## References
- https://external-secrets.io/latest/provider/bitwarden-secrets-manager/
- https://github.com/onedr0p/home-ops/blob/main/bootstrap/mod.just
- Related: [ADR-0001](0001-home-ops-as-reference.md), [design](../design.md)
