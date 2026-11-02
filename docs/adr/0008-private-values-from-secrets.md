# ADR-0008: Private values come from Bitwarden, never from git

The domain, the LAN layout (subnets, gateway, LoadBalancer IPs, node IPs, VLAN IDs) and the BGP ASNs are **private values**. They aren't credentials, but publishing them maps my network and ties the public repo to me. They live in Bitwarden Secrets Manager, and git holds only their names:

- **Flux side:** BWS project `kubernetes/apps` holds one secret per value, named `SECRET_<ROLE>` (`SECRET_DOMAIN`, `SECRET_LB_POOL`, `SECRET_KUBE_API_IP`, …). A `ClusterExternalSecret` named `cluster-secrets` syncs them into a Secret `cluster-secrets` in every namespace. The cluster-level Flux Kustomization patches every child Kustomization with `postBuild.substituteFrom: [{kind: Secret, name: cluster-secrets}]`, so manifests write `${SECRET_DOMAIN}`. One Secret per namespace is needed because Flux reads `substituteFrom` only from the Kustomization's own namespace, and this repo's Kustomizations live in their app's namespace.
- **Talos side:** values the templates need (e.g. `SECRET_SERVER_SUBNET`) live in BWS project `kubernetes/talos`, are injected by `fnox exec` like the Talos PKI and are read as `{{ ENV.SECRET_SERVER_SUBNET }}`. `strict` rendering fails on a missing one.
- **Docs:** ADRs, design and issues write `<role>` placeholders (`<kube-api-ip>` is `SECRET_KUBE_API_IP`). Hardware IDs (MACs, disk serials, WWIDs) are masked too; they aren't used in config, so they have no `SECRET_` entry.

This reverses the "no `postBuild.substituteFrom`, write the domain literally" convention. home-ops now writes its domain and IPs literally and uses `substituteFrom` only for single ESO-synced Secrets (e.g. `cloudflare-tunnel-id-secret`). Here that pattern applies to every app.

## Considered options

- **Literal values (home-ops' current choice):** simplest, and nothing extra has to sync before an app reconciles. Rejected: it publishes the LAN layout and the domain.
- **A SOPS-encrypted `cluster-secrets` (home-ops' former pattern):** rejected: ADR-0001 keeps all secret material out of git, even encrypted.
- **One `cluster-secrets` Secret in `flux-system`:** rejected: it only works if every Kustomization moves into `flux-system`, which reverses the app-namespace convention.

## Consequences

- The `cluster-secrets` ClusterExternalSecret is applied during bootstrap together with the ClusterSecretStore ([ADR-0006](0006-helmfile-bootstraps-cert-manager-and-eso.md)), so the Secret already exists in the bootstrapped namespaces when Flux starts. In a new namespace, the app's Kustomization fails until ESO has synced the Secret, then reconciles on retry.
- helmfile doesn't run Flux substitution. HelmRelease values of bootstrapped releases must not contain `${SECRET_*}`, so private values go in plain manifests (e.g. Cilium's `networking.yaml`), which only Flux applies.
- Substitution rewrites every `${VAR}` in a manifest. Shell scripts in ConfigMaps need `$${VAR}` or the `kustomize.toolkit.fluxcd.io/substitute: disabled` annotation.
- This is privacy, not secrecy. Substituted values appear in plain objects in the cluster, and the domain is still public through DNS and Certificate Transparency logs.
- A value needed by both Talos and Flux (e.g. the gateway IP) is stored in both BWS projects.
- Values already committed on `main` (the server subnet in the Talos templates, the IoT VLAN ID) stay in history. Future changes use the placeholder form.

## References

- https://fluxcd.io/flux/components/kustomize/kustomizations/#post-build-variable-substitution
- https://external-secrets.io/latest/api/clusterexternalsecret/
- https://github.com/onedr0p/home-ops/blob/main/kubernetes/apps/network/cloudflare-tunnel/ks.yaml
- Related: [design](../design.md), [ADR-0001](0001-home-ops-as-reference.md), [ADR-0004](0004-secret-zero-cluster-machine-account.md)
