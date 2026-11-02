# ADR-0007: Stay on Bitwarden Secrets Manager, US region

The cluster keeps **Bitwarden Secrets Manager on the US servers** for both the Talos PKI and the in-cluster secrets. Moving to Bitwarden's EU servers and switching to 1Password were both considered and rejected (decided by 2026-11-02).

## Considered options
- **Bitwarden EU:** data residency in the EU, but a migration of every secret and machine account, and new `apiURL`/`identityURL` values in the ClusterSecretStore and fnox.
- **1Password:** home-ops' own choice, so its `op://` references would copy verbatim, but it reverses [ADR-0001](0001-home-ops-as-reference.md)'s fnox/Bitwarden flow and adds a second paid service.

## Consequences
- The `bitwarden-secrets-manager` ClusterSecretStore and fnox use Bitwarden's default (US) endpoints; neither sets `apiURL` or `identityURL`.
- Revisiting the region later means a migration of both BWS projects (`kubernetes/talos`, `kubernetes/apps`) and the `mandalore` and `ESO` machine accounts.

## References
- https://bitwarden.com/help/server-geographies/
- https://external-secrets.io/latest/provider/bitwarden-secrets-manager/
