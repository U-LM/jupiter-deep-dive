# Storage

JUPITER user storage is Multi-Cluster GPFS exposed through shell variables.
System-wide capacities and project quotas are separate scopes. The table below
uses exact `jutil ... -U GB` labels from the 2026-09-02 snapshot.

## Project and user quotas

| Tier | Path | Soft / hard data limit | Soft / hard inodes | Retention | Backup |
| --- | --- | ---: | ---: | --- | --- |
| `HOME` | `/e/home/jusers/[redacted-user]/jupiter` | 19.074 / 20.981 GB | 80,000 / 82,000 | no purge policy stated | ISP to tape; no restore SLA inferred |
| `PROJECT` | `/e/project1/e-dev-2026d09-128` | 20,480 / 22,528 GB | 4,000,000 / 4,400,000 | project storage; post-project window unresolved | ISP to tape; no restore SLA inferred |
| `FSCRATCH` | `/e/fscratch/e-dev-2026d09-128` | 40,960 / 45,056 GB | 8,000,000 / 8,800,000 | purge eligible after 30 days by access and modification date; empty dirs 3 days | no |
| `SCRATCH` | `/e/scratch/e-dev-2026d09-128` | 204,800 / 215,040 GB | 8,000,000 / 8,800,000 | purge eligible after 90 days by access and modification date; empty dirs 3 days | no |

Quota source: [`data-quota.json`](evidence/live/data-quota.json) and
[`user-data-quota.json`](evidence/live/user-data-quota.json). Retention and backup
semantics: [JSC File Systems](https://apps.fz-juelich.de/jsc/hps/jupiter/filesystems.html).

## System-wide storage

JSC reports approximately `20 PB usable ExaFLASH`, `308 PB raw ExaSTORE` and
`379 PB ExaTAPE`. These capacities describe the whole service and do not expand
our account quotas. Current build-up documentation says ExaFLASH is still in
acceptance, even though our `FSCRATCH` quota already exists. Treat observed mount
availability as the operational source for each job. `ISP to tape` is a service
backup designation; it does not imply archival retention or a restore SLA.

## Supported transfer paths

JSC designates JUDAC as the external gateway to its parallel file systems.
External ingress or egress should use an approved JUDAC transfer client; the
current JUPITER bridge does not automate JUDAC access. Bulk payloads must not be
streamed through a JUPITER login session or the bridge's small-file helpers.

For internal staging between ExaSTORE and ExaFLASH, JSC provides the `nd` Data
Mover client on JUPITER and JUDAC. The command submits work to dedicated Data
Mover nodes, so it can be issued as a lightweight control operation before a GPU
allocation:

```bash
eurohpc-bridge run -- nd copy \
  /e/project1/e-dev-2026d09-128/dataset \
  /e/fscratch/e-dev-2026d09-128/dataset
eurohpc-bridge run -- nd task list
eurohpc-bridge run -- nd task status TASK_ID
```

The `nd copy` client follows progress by default while the transfer task itself
is asynchronous. Record its task ID and verify completion before submitting the
dependent compute job. Sources: [JUPITER Data Transfer](https://apps.fz-juelich.de/jsc/hps/jupiter/data-transfer.html)
and [Data Mover Service](https://apps.fz-juelich.de/jsc/hps/jupiter/datamover.html).

## Data placement policy

| Data | Primary tier | Promotion / expiry rule |
| --- | --- | --- |
| Source, scripts, small configs | `PROJECT`, with minimal config in `HOME` | version in Git; avoid large files in `HOME` |
| Canonical licensed or curated corpus | `PROJECT` | keep provenance manifest and checksums |
| Expanded tokenizer shards | `SCRATCH` | regenerate or promote validated subset |
| Hot training shards | `FSCRATCH` when measured I/O warrants it | refresh access only through genuine use; copy durable result out |
| Active checkpoints | `FSCRATCH` or `SCRATCH` | promote milestone checkpoints to `PROJECT` |
| Synthetic generations | `SCRATCH` | validate, deduplicate, then promote accepted data |
| Final metrics and compact logs | `PROJECT` | include run/job IDs and hashes |

## Operational rules

- Use `$HOME`, `$PROJECT`, `$FSCRATCH` and `$SCRATCH` variables in jobs when available.
- Use JUDAC for external transfer and `nd` Data Mover tasks for internal ExaSTORE/ExaFLASH staging; avoid paid node idle time for copies.
- Package many small files into sharded archives or container formats to protect inode quota.
- Check both bytes and inodes with `jutil project dataquota` before campaigns.
- Do not treat scratch as backup. Checkpoint promotion must be explicit and verified.
- Export durable artifacts before 2027-02-28; post-project `PROJECT` retention is unresolved.
- Avoid synthetic storage benchmarks during Early Access unless a workload decision requires them.
