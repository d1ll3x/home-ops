# ⎈ Kubernetes Homelab

My homelab running on Kubernetes: [Talos Linux](https://www.talos.dev/) nodes, [Cilium](https://cilium.io/) networking and [Flux](https://fluxcd.io/) GitOps. I build it by hand to learn how to operate Kubernetes, so every change comes with the reasoning behind it.

## 🚧 Current state

The proof of concept runs on a single node, **nautilus**: a control plane that also runs workloads. Two more nodes, **calypso** and **proteus**, will join later. Nothing is live yet. The cluster config is being built milestone by milestone, and the Talos layer (M1) is close to done.

| Area               | What's in the repo                                                                                                                                                                         |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| OS                 | Talos Linux, configured through minijinja templates (`kubernetes/talos/`), rendered and applied with mise tasks                                                                            |
| Networking         | Cilium with BGP to the UniFi gateway (ECMP across nodes), Multus, Envoy Gateway (`envoy-internal`)                                                                                         |
| DNS & certificates | external-dns writes to UniFi DNS through its webhook. cert-manager gets Let's Encrypt certificates through Cloudflare DNS-01                                                               |
| Secrets            | Bitwarden Secrets Manager. [fnox](https://github.com/jdx/fnox) injects secrets on the workstation, External Secrets Operator in the cluster. No secret material in git, not even encrypted |
| GitOps             | Flux Operator + FluxInstance. Bootstrap through helmfile (Cilium, CoreDNS, Spegel, cert-manager, ESO)                                                                                      |
| Storage & data     | Longhorn V1 (local NVMe; replicated from M10), snapshot-controller, CloudNativePG, Longhorn backups to Scaleway Object Storage                                                             |
| Remote access      | Tailscale as a Talos extension that advertises the LoadBalancer and node IPs as subnet routes. The tailnet policy and split DNS are Terraform (`terraform/`), with state in Scaleway S3    |
| Tooling            | mise (tool versions, tasks), just, lefthook pre-commit (oxfmt, zizmor, terraform fmt)                                                                                                      |

Work is tracked in [GitHub issues and milestones](https://github.com/d1ll3x/home-ops/milestones), M1 to M9: Talos → bootstrap → BGP → basics → secrets & certs → gateway & DNS → rebuild drill → storage → three nodes.

## ✨ Roadmap

- 🏗️ **Finish M2–M9**: bootstrap the node, BGP peering, certificates, gateway and DNS, a full rebuild drill, storage, and finally the three-node cluster.
- ⬆️ **Renovate**: automatic update PRs for Helm charts, container images, Talos/Kubernetes versions, mise tools and Terraform providers.
- 👷 **GitHub Actions**:
  - validate every PR: Flux/kustomize builds, schema checks, lint and formatting;
  - run `terraform plan` on PRs and `apply` on merge for the tailnet, so it no longer runs from my workstation;
  - validate the Renovate config.
- 📈 **Observability**: kube-prometheus-stack and grafana-operator. Their CRDs are already part of the bootstrap.

## 👥 Thanks

This repo stands on the shoulders of these, and I check how they solve a problem before designing my own approach:

- [onedr0p/home-ops](https://github.com/onedr0p/home-ops): the blueprint for the layout, Flux setup and much of the app configuration.
- [bjw-s-labs/home-ops](https://github.com/bjw-s-labs/home-ops): a second reference for the same patterns, and many small details.
- [prateekjaindev/homelab](https://github.com/prateekjaindev/homelab): a three-node Talos homelab with Cilium, Gateway API and Tailscale, plus the blog series that comes with it.

And thanks to the [Home Operations](https://discord.gg/home-operations) community behind most of the tooling used here.
