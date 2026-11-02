# ADR-0003: miroir local-only on the NVMe for persistent storage

Persistent volumes come from **miroir** (home-operations/miroir), a CSI driver on LVM-thin. The 1 TB NVMe is handed to it as a Talos `RawVolumeConfig` named `miroir` (partition `r-miroir`), declared **per node in layer 3** (`kubernetes/talos/nodes/controlplane/<node>.yaml.j2`) with `minSize: 1GiB` and `grow: true` so it takes the rest of the disk. Each node file picks its own disk and sizes, so nodes with different hardware need no layer-1 change. `dm_thin_pool` is loaded through `KernelModuleConfig` in layer 1. With one node it runs **local-only**: a single `replicas: "1"` StorageClass plus a VolumeSnapshotClass. The `drbd` extension and the `drbd`/`drbd_transport_tcp` modules are loaded **from the start**, so nodes 2 and 3 join without a Talos upgrade.

## Considered options
- **Rook-Ceph:** the disks aren't suitable for Ceph, and Ceph is pointless on one node anyway.
- **Longhorn:** heavier, and needs iSCSI extensions.
- **Plain `UserVolumeConfig data` (XFS at `/var/mnt/data`) + local-path:** simplest, but no CSI snapshots or clones, so no snapshot-based backups (kopiur) later.
- **The volume in layer 1 (home-ops' `miroir-slow`):** one disk selector for every node; dropped 2026-10-18 because nodes with different disks would need a layer-1 change.
- **Load DRBD only once a second node exists:** dropped 2026-10-18, because adding the extension later means a Talos upgrade on every node.

## Consequences
- The NVMe no longer has a plain filesystem mount, so there's no `/var/mnt/data` for hostPath use.
- A `replicas: 1` volume stays pinned to revan for good: it can't gain DRBD in place, even with DRBD loaded. Going replicated means a snapshot + restore into a replicated StorageClass for each volume (planned in M9). The data is kept; each workload is repointed to its new PVC.
- The name differs from home-ops (`miroir-slow`): copy its miroir manifests with `r-miroir`.
- Every new node file must declare the volume, or that node has no miroir pool.
- It's a young (2026-06), essentially single-maintainer AGPL project. Back up data independently of miroir.

## References
- https://github.com/home-operations/miroir
- https://miroir.home-operations.com/
- https://docs.siderolabs.com/
- Related: [design](../design.md)
