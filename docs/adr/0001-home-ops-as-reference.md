# ADR-0001: onedr0p/home-ops as reference, no secrets in git

The cluster follows [onedr0p/home-ops](https://github.com/onedr0p/home-ops) instead of onedr0p/cluster-template, because home-ops commits no secret material at all, not even encrypted. Where home-ops resolves `op://` references with 1Password (`op inject`), the cluster uses **Bitwarden Secrets Manager via fnox**, and templates read `{{ ENV.X }}` under `fnox exec`. This reverses the 2026-10-10 SOPS/age decision.

## Consequences
- The repo is safe to publish as-is, and a rebuild needs the repo plus Bitwarden.
- Single point of failure: the `mandalore` machine-account token in the OS keychain. On a new workstation it has to be recovered by hand.
- home-ops can't be copied verbatim. Every `op://` reference and `op inject` step needs a fnox equivalent, and home-ops' Ceph, 3-node and VLAN choices don't fit my cluster.

## References
- https://github.com/onedr0p/home-ops
- https://fnox.jdx.dev/providers/bitwarden-sm
- Related: [ADR-0002](0002-just-and-minijinja-for-talos.md), [design](../design.md)
