# ADR-0005: The Kubernetes API endpoint is a name on a Cilium BGP LoadBalancer IP

kotor's API endpoint is **`https://k8s.internal:6443`**. Technitium resolves `k8s.internal` to **`192.168.21.10`**, the IP of a Cilium `LoadBalancer` Service named **`kube-api`** in front of the apiservers. Cilium announces it to UniFi over BGP like every other LoadBalancer IP (`envoy-internal` `192.168.21.11`, `envoy-external` `192.168.21.15`). The Service uses `externalTrafficPolicy: Local`, so only nodes with a healthy apiserver attract traffic, and UniFi's `maximum-paths 3` spreads clients across the control planes with ECMP. Each node also gets `<node>.internal` (`revan`, `malgus`, `bane` on `.201`–`.203`, with PTRs in `20.168.192.in-addr.arpa`) for talosctl. There is no `kotor.internal` zone. This is home-ops' design (`k8s.internal` → `kube-api`). Every kotor node is a control plane that also runs workloads; configs are written for three, and the proof of concept runs one.

## Considered options
- **DNS round-robin (one A record per node)**: the first version of this ADR. No extra moving parts, but no health checks: clients try a dead node's address first and wait for a timeout.
- **Talos shared IP (`Layer2VIPConfig`)**: needs nothing external, but one node owns the IP at a time, failover relies on an etcd election, and it adds nothing on one node.
- **External load balancer (e.g. HAProxy on the RPi5)**: health-checked, but a second box to run.
- **A single node IP**: simplest, but adding nodes changes the endpoint, every kubeconfig and the cert SANs.
- **`kotor.internal` as the API name, nodes as `<node>.kotor.internal` or `<node>.k8s.internal`**: dropped 2026-10-18 for home-ops' `k8s.internal` and the shorter `<node>.internal`.

## Consequences
- **The named endpoint depends on Cilium.** Before Cilium runs (M1–M2) and whenever the CNI is down, use a node IP: `https://192.168.20.201:6443` for Kubernetes, and node IPs for the Talos API (port 50000 is never behind `kube-api`). The `kubeconfig` stage points at the node IP until `k8s.internal` answers. Talos itself uses KubePrism (`localhost:7445`), so the nodes don't depend on the name.
- **The IP lives in the BGP pool `192.168.21.0/24`, not the server VLAN**: a BGP-announced address inside `192.168.20.0/24` would be unreachable from other VLAN 20 hosts, since they ARP for it instead of asking the router.
- **Certificate SANs:** `k8s.internal` only; clients must use the name, since `https://192.168.21.10:6443` fails TLS verification.
- **Firewall:** VLAN 30 → `192.168.21.10` TCP 6443.
- **Adding a node** means a BGP peer on UniFi, a `<node>.internal` record (all three already exist) and a talosctl endpoint. The API endpoint and SANs stay the same. Spreading single clients across nodes also needs L4 ECMP hashing on the gateway (M9).

## References
- https://github.com/onedr0p/home-ops/blob/main/bootstrap/README.md
- https://docs.siderolabs.com/talos/v1.14/troubleshooting/troubleshooting#kubernetes-control-plane-endpoint
- https://docs.siderolabs.com/talos/v1.14/configure-your-talos-cluster/system-configuration/kubeprism
- Related: [ADR-0003](0003-miroir-local-only-storage.md), [design](../design.md)
