# Allocation and accounting

## Project entitlement

`jutil project cpuquota` reported the following fixed allocation for
`e-dev-2026d09-128`:

| Quantity | Value | Meaning | Evidence |
| --- | ---: | --- | --- |
| Core-hours | 1,008,000 | JSC quota unit | `observed` |
| Node-hours | 3,500 | `1,008,000 / 288` | `derived` |
| Physical GH200-hour equivalent | 14,000 | `3,500 × 4` | `derived` |
| Period | 2026-09-01 to 2027-02-28 | Fixed accounting period | `observed` |

`14,000 GH200-hours` is a physical-capacity equivalent, not a separate JSC
budget. JSC tracks the allocation in core-hours. Full utilization of every
allocated node produces four useful GPU-hours per node-hour.

## Charging rule

The [JSC Batch System](https://apps.fz-juelich.de/jsc/hps/jupiter/batchsystem.html)
states that compute nodes are exclusive, the minimum allocation is one
288-core node, and charging is allocated nodes multiplied by wall-clock time.
The number of requested GPUs does not reduce that charge.

Probe `1618999` tested the boundary directly:

| Field | Requested | Allocated / observed |
| --- | ---: | ---: |
| Nodes | 1 | 1 |
| CPU | 72 | 288 |
| GPUs | 1 | 4 in `AllocTRES` |
| Task environment | one-GPU request | `CUDA_VISIBLE_DEVICES=0`; runtime count not measured |
| Elapsed | 2-minute limit | 16 seconds |
| `CPUTimeRAW` | n/a | 4,608 CPU-seconds = `288 × 16` |

The probe observed `CUDA_VISIBLE_DEVICES=0`, CPU binding to cores 0-71 and all
four physical devices in `nvidia-smi -L`. It did not call `cudaGetDeviceCount`,
so CUDA runtime visibility remains open. Slurm's full-node reservation is
independently proven by `AllocTRES`. Four independent one-GPU workloads should
therefore run as four tasks or job steps inside one node allocation.

## Calculator

For `N` nodes and elapsed wall time `H` hours:

```text
node-hours              = N × H
core-hours              = N × H × 288
physical GH200-hours    = N × H × 4
useful GPU utilization  = active GPU-hours / physical GH200-hours
```

| Example | Node-hours | Core-hours | Physical GH200-hours |
| --- | ---: | ---: | ---: |
| 1 node × 2 minutes | 0.0333 | 9.6 | 0.1333 |
| 1 node × 30 minutes | 0.5 | 144 | 2 |
| 8 nodes × 6 hours | 48 | 13,824 | 192 |
| 16 nodes × 12 hours | 192 | 55,296 | 768 |

## Probe budget

The two newly launched probes ran for 19 and 16 elapsed seconds. Their raw
allocated time is `35 / 3,600 = 0.009722 node-hours`. Their requested time
limits totaled seven minutes, which bounded worst-case use to
`7 / 60 = 0.116667 node-hours`.

Central `jutil` still reported zero consumed core-hours immediately afterward.
JSC documents daily quota ingestion, so this raw Slurm time is not labeled as
the final debited cost and does not establish a minimum rounding unit. `sacct`
is the immediate source for elapsed/TRES; `jutil` remains the quota ledger after
refresh.

## Scheduling rules

- Default wall time is one hour; JSC documents an effective 12-hour maximum.
- Short, realistic wall-time requests improve backfill opportunities.
- Pending jobs consume no allocation; running allocations are charged even when idle.
- `largebooster` was `DOWN` in the snapshot and is excluded from all probes.
- Preserve job IDs, `sacct -X` output and run configuration for every campaign.
