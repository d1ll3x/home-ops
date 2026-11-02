# ADR-0002: just + minijinja render Talos config (no topf, no talhelper)

Talos machine config is rendered by **minijinja-cli** from three template layers and driven by **just** recipes, as in home-ops. Talos generators are not used: talhelper is archived, and topf silently writes plaintext secrets when sops fails, and adds an abstraction between me and the Talos config.

- **Layers:** `kubernetes/talos/cluster.yaml.j2` (all nodes) → `kubernetes/talos/controlplane.yaml.j2` (role) → `kubernetes/talos/nodes/controlplane/revan.yaml.j2` (node), combined with `talosctl machineconfig patch`. A CA cert and its key are always patched together, because a key-only patch blanks the cert.
- **Task runner split:** just owns tasks (`.justfile`, `kubernetes/talos/mod.just`). mise owns tools (including `just`) and env. `.mise/tasks/` goes away.
- **Rendered output is never written to disk:** `render-config` streams the merged config to stdout and `apply-node` pipes it into `talosctl apply-config -f /dev/stdin`, as in home-ops. Nothing to ignore, nothing to clean up.
- **Accepted risk:** layers reach `talosctl machineconfig patch` through `<( )`, whose exit status bash ignores, so a failed layer render can reach talosctl as an empty patch. The guard is the `--dry-run` diff before every apply.

## Considered options
- topf (dropped 2026-10-17), talhelper (archived).
- Rendering inside the repo under `talos/rendered/`: rejected, because one `git add -A` away from publishing the PKI.
- Rendering to files under `$XDG_RUNTIME_DIR/kotor/` (temp dir per layer, so `set -e` catches a failed layer): the first choice, dropped 2026-10-18 in favour of the home-ops pipe. Inspect a render with `just talos render-config <node> | less` instead.

## References
- https://just.systems/man/en/
- https://github.com/mitsuhiko/minijinja/tree/main/minijinja-cli
- https://github.com/onedr0p/home-ops/blob/main/talos/mod.just
- Related: [ADR-0001](0001-home-ops-as-reference.md), [design](../design.md)
