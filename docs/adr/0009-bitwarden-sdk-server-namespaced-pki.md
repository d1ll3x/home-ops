# ADR-0009: bitwarden-sdk-server gets a namespaced self-signed PKI; cert-manager gates on issuer health, not on Bitwarden

`letsencrypt-production` needs the Cloudflare token, which comes from Bitwarden through the `bitwarden-secrets-manager` ClusterSecretStore. That store talks to `bitwarden-sdk-server` over TLS, and cert-manager issues the server's cert. This looks like a cycle, but no Flux gate closes it:

- The `cert-manager` Flux Kustomization health-checks only the HelmRelease and `letsencrypt-production`. An ACME ClusterIssuer turns Ready once its Let's Encrypt account registers, which needs no secret.
- The Cloudflare ExternalSecret sits in the same Kustomization but is not health-checked (no `wait`). ESO retries it until the store is Valid. Only the first DNS-01 challenge needs the token.
- `bitwarden-secrets-manager` `dependsOn: cert-manager` and issues its cert from the controller alone.

Order: `cert-manager` (controller + issuers) → `bitwarden-secrets-manager` (PKI, sdk-server, store) → the ExternalSecret syncs → certificates issue. This matches onedr0p's `cert-manager/app` (issuers and ExternalSecret beside the HelmRelease).

The sdk-server PKI follows the chain in `bitwarden-sdk-server`'s `hack/` (self-signed → CA `bitwarden-ca` → leaf `bitwarden-tls-certs`), but with namespaced `Issuer`s in `external-secrets`, not `ClusterIssuer`s.

## Considered options

- **Separate `cert-manager-issuers` Kustomization (`issuers/`) depending on Bitwarden:** an explicit chain, but it adds a directory and a Kustomization to guard against something health checks already avoid.
- **Copy `hack/` as-is (ClusterIssuers, CA secret in `cert-manager`):** it's a kind e2e fixture in `default`. The CA ClusterIssuer reads its secret from the `cert-manager` namespace, which clashes with `--namespace=external-secrets` (helmfile hook) and Flux `targetNamespace: external-secrets`. A cluster-wide CA would also be trusted wider than needed: only the ESO controller calls the sdk-server.

## Consequences

- Never add the Cloudflare ExternalSecret (or `wait: true`) to the `cert-manager` Kustomization's health checks: that closes the cycle.
- The ExternalSecret CRD must exist before Flux applies `cert-manager/app`. The helmfile bootstrap installs ESO first ([ADR-0006](0006-helmfile-bootstraps-cert-manager-and-eso.md)).
- The sdk-server's CA is trusted only by the ClusterSecretStore (`caProvider` → `bitwarden-tls-certs`/`ca.crt`).

## References

- https://github.com/external-secrets/bitwarden-sdk-server/tree/main/hack
- https://github.com/onedr0p/home-ops/tree/main/kubernetes/apps/cert-manager/cert-manager
- Related: [ADR-0006](0006-helmfile-bootstraps-cert-manager-and-eso.md), [design](../design.md)
