# homeops-talos

A Talos Linux Kubernetes homelab of control-plane nodes that also run workloads (three planned, one today), rebuilt from this repo plus Bitwarden only, modelled on onedr0p/home-ops.

## Machines and identities

**kotor**:
The Kubernetes cluster built by this repo.
_Avoid_: main, homelab, k8s

**revan**:
kotor's first node, a control-plane node that also runs workloads.
_Avoid_: k8s-0, server

**API endpoint**:
The one name every client uses to reach kotor's Kubernetes API: `k8s.internal`, which resolves to the `kube-api` LoadBalancer IP that Cilium announces over BGP.
_Avoid_: master, Talos VIP

**mandalore**:
The operator's workstation and the Bitwarden machine account named after it. It is the only identity that can read the Talos PKI.
_Avoid_: laptop, desktop, admin account

**Machine account**:
A Bitwarden Secrets Manager identity scoped to one device or one cluster, with its own access token. `mandalore` is the workstation's; `ESO` is kotor's.
_Avoid_: service account, API key, user

**BWS project**:
A Bitwarden Secrets Manager project that groups secrets and the machine accounts allowed to read them. `kubernetes/talos` holds the Talos PKI and `kubernetes/apps` holds the in-cluster secrets.
_Avoid_: vault, collection

## Talos configuration

**Layer**:
One template in the stacked Talos config: **cluster** (all nodes), **role** (control plane or worker) or **node** (one machine). Later layers patch earlier ones.
_Avoid_: patch file, overlay

**Render**:
Turning the layers plus secrets into one complete machine config for a node.
_Avoid_: generate, build, template (as a verb)

**Rendered config**:
The output of a render. It contains the cluster PKI and lives only outside the repo.
_Avoid_: machine config file, output

**Schematic**:
The Image Factory definition of extensions and kernel args, whose ID selects the Talos installer image.
_Avoid_: image config, extensions list

**Talos PKI**:
The machine and cluster CAs, keys and tokens that identify kotor. Created once and never regenerated.
_Avoid_: Talos secrets bundle, secrets.yaml

## Secrets

**Secret zero**:
The one credential that has to be placed in the cluster by hand at bootstrap, so that every other secret can then be fetched automatically: the `ESO` machine account's token.
_Avoid_: bootstrap secret, seed secret

**In-cluster secret**:
A secret synced into Kubernetes from the `kubernetes/apps` BWS project by External Secrets Operator.
_Avoid_: app secret, k8s secret (when meaning the source)

**Private value**:
A value that isn't a credential but maps my network or names me: the domain, subnets, IPs, VLAN IDs, ASNs. Stored in BWS as `SECRET_<ROLE>`, written as `${SECRET_<ROLE>}` in manifests and `<role>` in docs.
_Avoid_: config value, setting, secret (when meaning a credential)

## Storage

**miroir pool**:
The NVMe handed to miroir as raw block storage, from which volumes are carved.
_Avoid_: data disk, data volume

**Local-only volume**:
A persistent volume with a single replica, pinned to the node it was created on.
_Avoid_: hostpath volume, unreplicated PV
