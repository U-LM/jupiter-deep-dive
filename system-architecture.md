# System architecture

Стан чисел: `2026-09-02`. JUPITER має GPU Booster і окремий general-purpose
Cluster Module. Cluster Module ще будується, тому цей аудит не переносить його
CPU-node характеристики на Booster. [JSC Configuration](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html)
та [JSC Build-Up](https://apps.fz-juelich.de/jsc/hps/jupiter/buildup.html) прямо
позначають систему як Early Access / build-up.

## Рівні місткості

| Scope | Nodes | GH200 | Grace cores | Evidence |
| --- | ---: | ---: | ---: | --- |
| Installed Booster design | 5,884 | 23,536 | 1,694,592 | `official` + `derived`, `jsc-config` |
| Slurm-visible `booster` snapshot | 5,643 | до 22,572 фізичних GPU | до 1,625,184 cores | `observed`, `live-sinfo` |
| Idle у момент snapshot | 268 | до 1,072 | до 77,184 | `observed`, `live-sinfo` |
| Project allocation | variable | до 4 на allocated node | 288 billing cores/node | `observed`, `live-cpuquota` + `live-partition-booster` |

Slurm-visible count є оперативним станом partition, а не новою специфікацією
системи. Snapshot містив `5,348 alloc`, `268 idle`, `16 resv`, `10 drain` і
`1 drain*` node. Значення змінюються протягом дня.

## Installed Booster

Один compute node містить `4 × NVIDIA GH200`, тобто `288` Grace CPU cores,
`480 GB` Grace LPDDR5X і `384 GB` Hopper HBM3. Installed totals:

| Quantity | Calculation | Result | Evidence |
| --- | --- | ---: | --- |
| GH200 | `5,884 × 4` | 23,536 | `derived` |
| Grace cores | `5,884 × 288` | 1,694,592 | `derived` |
| LPDDR5X | `5,884 × 480 GB` | 2,824,320 GB | `derived` |
| HBM3 | `5,884 × 384 GB` | 2,259,456 GB | `derived` |
| Nominal LPDDR5X + HBM3 aggregate | `5,884 × (480 + 384) GB` | 5,083,776 GB across separate pools | `derived` |

JSC reports HPL performance of approximately `1 ExaFLOP/s FP64` for JUPITER.
This is a system benchmark, not an application throughput estimate.
[JUPITER Technical Overview](https://www.fz-juelich.de/en/jsc/jupiter/tech/)

## Physical and fabric hierarchy

```text
JUPITER
└── Booster: 25 DragonFly+ groups
    └── 5 rack positions per group
        └── up to 48 compute nodes per rack
            └── 4 GH200 per node
                ├── Grace: 72 cores + 120 GB LPDDR5X
                └── Hopper: 96 GB HBM3
```

`240` nodes form a full DragonFly+ group across `5` racks. Node names encode
rack and position, for example `jpbo-024-02`. Racks `001-122` have 48 node
positions, rack `123` has 28, and racks `124-125` have no compute nodes:
`122 × 48 + 28 = 5,884`. The hierarchy is documented by
[JSC Batch System](https://apps.fz-juelich.de/jsc/hps/jupiter/batchsystem.html).

The [Eviden XH3000 brochure](https://eviden.com/wp-content/uploads/2024/10/Eviden-brochure-BullSequanaXH3000-HPC.pdf)
describes blade-based packaging, but the frozen sources do not establish the
as-built compute-node-to-blade ratio for JUPITER. This audit therefore reports
rack and node counts while leaving blade count as an open JSC confirmation item.

## Network and cooling

Each node exposes `4 × ConnectX-7 NDR200` HCAs. Nominal node injection bandwidth
is `800 Gbit/s`. The common fabric uses NVIDIA Quantum InfiniBand NDR in a
DragonFly+ topology with adaptive routing. Each node has one HCA local to each
Grace CPU locality group, confirmed by probe `1618998`.

### Data-path bandwidth

| Path or component | Published peak | Decimal comparison | Scope and limitation |
| --- | ---: | ---: | --- |
| HBM3 ↔ local Hopper GPU | 4 TB/s | 4,000 GB/s | per GPU local-memory peak |
| Grace LPDDR5X ↔ local CPU | 512 GB/s | 512 GB/s | per 120 GB Grace CPU memory controller |
| paired Grace CPU ↔ Hopper GPU | 900 GB/s aggregate | 900 GB/s | coherent NVLink-C2C inside one GH200 |
| Grace CPU ↔ Grace CPU | 100 GB/s per direction | 200 GB/s aggregate pair notation | cNVLink CPU pair; JSC summary wording differs, so do not treat as measured throughput |
| Hopper GPU ↔ Hopper GPU | 300 GB/s aggregate | 150 GB/s per direction | per GPU pair over NVLink4 inside one node |
| node ↔ L1 fabric | 4 × 200 Gbit/s | 100 GB/s raw per node | endpoint injection ceiling across four HCAs |
| switch ↔ switch | 400 Gbit/s per link | 50 GB/s raw per link | DragonFly+ building block; not rack throughput |
| node ↔ node, same rack | no fixed figure published | ≤100 GB/s raw per endpoint | route, rails, protocol and contention apply |
| rack ↔ rack, same group | no aggregate published | 50 GB/s raw per switch link | number of active links and routes varies |
| DragonFly+ group ↔ group | no aggregate published | 50 GB/s raw per switch link | adaptive routing; endpoint injection still applies |

One full Booster DragonFly+ group contains `15` L1 and `16` L2 switches. JSC
shows node HCAs connected to L1 with split cables and L2 global links leaving the
group. The third rack contains the sixteenth L2 switch; each rack contains three
L1 switches. JSC publishes link rates, but it does not publish a single guaranteed application
throughput for a node pair, rack pair or group pair. Converting `Gbit/s` to
`GB/s` divides by eight and still leaves protocol overhead, collective algorithm,
message-size, congestion and placement effects. Multi-node planning therefore
needs measured NCCL or CUDA-aware MPI bandwidth for the actual Slurm layout.

The machine uses Eviden BullSequana XH3000 direct liquid cooling. Cooling and
rack packaging are system-level characteristics; they do not change the Slurm
billing unit.

## Operational caveats

- `booster` was available in the snapshot; `largebooster` was `DOWN`.
- Documentation may temporarily lag the running Slurm configuration.
- Node state, installed count and account entitlement must be reported separately.
- Cluster Module resources are excluded from Booster workload calculations.
