# ADR-0006: helmfile bootstraps cert-manager and External Secrets, not only the CNI and Flux

The helmfile bootstrap (`kubernetes/bootstrap/helmfile/apps.yaml`) installs, in order: cilium → coredns → spegel → **cert-manager → external-secrets → bitwarden-secrets-manager** → flux-operator → flux-instance. The `bitwarden-secrets-manager` release's hooks issue the `bitwarden-tls-certs` Certificate before its pod mounts it, and apply the `bitwarden-secrets-manager` ClusterSecretStore after it syncs. Flux then adopts every release, as it does the CNI. This is home-ops' shape (it bootstraps cert-manager, ESO and 1Password Connect the same way), and it reverses the first plan, which left cert-manager and ESO to Flux in M5.

## Considered options
- **Bootstrap only cilium, coredns, spegel and Flux; Flux installs cert-manager and ESO in M5:** the first plan. Fewer bootstrap releases, but in-cluster secrets only become available after Flux has reconciled cert-manager, ESO and the store in order.

## Consequences
- When Flux starts, the ClusterSecretStore already exists, so any Flux-managed app can depend on an ExternalSecret from its first reconcile.
- The cert-manager and external-secrets app folders (`ocirepository.yaml` + `helmrelease.yaml`) must exist before the first `just bootstrap cluster`, because helmfile reads chart and values from them.
- The M5 tasks shrink to proving what bootstrap installed: the `selfsigned` issuer is Ready, the store is Valid, a test ExternalSecret syncs.
- Secret zero must be in the cluster before the `apps` stage, which the `base` stage guarantees ([ADR-0004](0004-secret-zero-cluster-machine-account.md)).

## References
- https://github.com/onedr0p/home-ops/tree/main/bootstrap/helmfile
- Introduced in `0cd328d` and `2a0ccf3`
- Related: [design](../design.md)
