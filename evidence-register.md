# Evidence register

Generated from [`facts.json`](facts.json) at `2026-09-02T09:22:55Z`. 
Facts, calculations, probes, storage tiers and scenarios carry explicit provenance metadata.

## Claim register

| Claim ID | Value | Unit | Scope | Type | Confidence | Sources | Note |
| --- | ---: | --- | --- | --- | --- | --- | --- |
| `system.modules` | 2 | modules | JUPITER system | `official` | high | [`jsc-tech`](https://www.fz-juelich.de/en/jsc/jupiter/tech/) | GPU Booster and general-purpose Cluster Module; storage is separate. |
| `booster.nodes.installed` | 5884 | nodes | Booster installed design | `official` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) |  |
| `booster.nodes.slurm-visible` | 5643 | nodes | booster partition at snapshot | `observed` | high | [`live-sinfo`](evidence/live/sinfo.txt) | Installed capacity and current partition membership are different scopes. |
| `booster.nodes.idle` | 268 | nodes | booster partition at snapshot | `observed` | high | [`live-sinfo`](evidence/live/sinfo.txt) |  |
| `booster.gh200.total` | 23536 | GH200 | Booster installed design | `derived` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) | 5,884 nodes × 4 GH200 per node. |
| `booster.grace-cores.total` | 1694592 | cores | Booster installed design | `derived` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) | 5,884 nodes × 288 cores per node. |
| `node.gh200` | 4 | GH200 | Booster node | `official` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) |  |
| `node.cpu-cores` | 288 | cores | Booster node | `official` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html), [`live-partition-booster`](evidence/live/partition-booster.txt) |  |
| `node.lpddr` | 480 | GB | Booster node physical memory | `official` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) |  |
| `node.hbm` | 384 | GB | Booster node physical memory | `derived` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) | 4 GPUs × 96 GB HBM3. |
| `node.coherent-memory` | 864 | GB | Booster node physical memory | `derived` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html), [`nvidia-cuda-memory`](https://docs.nvidia.com/cuda/cuda-programming-guide/02-basics/understanding-memory.html) | LPDDR and four HBM pools remain distinct NUMA resources with different placement and capacity constraints; 864 GB is not fungible host DRAM. |
| `node.slurm-memory` | 878535 | M | booster Slurm node | `observed` | high | [`live-partition-booster`](evidence/live/partition-booster.txt), [`topology-1618998`](evidence/probes/jupiter-topology-1618998.out) | Eight populated NUMA domains sum to 899,620,736 kB (878,535.875 MiB), whose integer-MiB floor equals observed RealMemory=878535M. The evidence does not establish whether Slurm derived or was configured with that value; LPDDR and HBM remain distinct pools. |
| `gpu.hbm` | 96 | GB | one GH200 GPU | `official` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html), [`gpu-baseline-output`](evidence/probes/jupiter-gpu-check-1618664.out) | nvidia-smi reports 97,871 MiB; the 120 GB product label refers to Grace-side LPDDR. |
| `gpu.hbm-bandwidth` | 4 | TB/s | one Hopper GPU | `official` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) |  |
| `cpu.lpddr-bandwidth` | 512 | GB/s | one Grace CPU | `official` | medium | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html), [`jsc-tech`](https://www.fz-juelich.de/en/jsc/jupiter/tech/) | JSC pages use both 500 and 512 GB/s; 512 is the current configuration value. |
| `interconnect.c2c` | 900 | GB/s | one GH200 | `official` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html), [`nvidia-grace`](https://docs.nvidia.com/dccpu/grace-perf-tuning-guide/) |  |
| `interconnect.gpu-pair` | 300 | GB/s | Booster node GPU pair | `official` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) |  |
| `network.hca-per-node` | 4 | HCAs | Booster node | `official` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) |  |
| `network.bandwidth-node` | 800 | Gbit/s | Booster node | `derived` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) | 4 HCAs × 200 Gbit/s. |
| `numa.ids` | 36 | NUMA IDs | Booster node | `official` | high | [`jsc-affinity`](https://apps.fz-juelich.de/jsc/hps/jupiter/affinity.html), [`topology-1618998`](evidence/probes/jupiter-topology-1618998.out) |  |
| `numa.active-domains` | 8 | NUMA domains | Booster node | `official` | high | [`jsc-affinity`](https://apps.fz-juelich.de/jsc/hps/jupiter/affinity.html), [`topology-1618998`](evidence/probes/jupiter-topology-1618998.out) | CPU domains 0–3 and HBM domains 4, 12, 20, 28; other IDs are reserved for unused MIG topology. |
| `numa.locality-map` | [{"rank":0,"cpuCores":"0-71","cpuNuma":0,"hbmNuma":4,"gpu":0,"nic":"mlx5_0"},{"rank":1,"cpuCores":"72-143","cpuNuma":1,"hbmNuma":12,"gpu":1,"nic":"mlx5_1"},{"rank":2,"cpuCores":"144-215","cpuNuma":2,"hbmNuma":20,"gpu":2,"nic":"mlx5_2"},{"rank":3,"cpuCores":"216-287","cpuNuma":3,"hbmNuma":28,"gpu":3,"nic":"mlx5_3"}] | mapping | Booster node jpbo-024-02, job 1618998 | `observed` | high | [`topology-1618998`](evidence/probes/jupiter-topology-1618998.out) |  |
| `topology.gpu-mesh` | NV6 full mesh | topology | Booster node jpbo-024-02, job 1618998 | `observed` | high | [`topology-1618998`](evidence/probes/jupiter-topology-1618998.out) |  |
| `topology.racks` | 125 | racks | Booster fabric | `official` | high | [`jsc-batch`](https://apps.fz-juelich.de/jsc/hps/jupiter/batchsystem.html) |  |
| `topology.nodes-full-rack` | 48 | nodes | Booster rack | `official` | high | [`jsc-batch`](https://apps.fz-juelich.de/jsc/hps/jupiter/batchsystem.html) |  |
| `topology.nodes-partial-rack` | 28 | nodes | Booster rack 123 | `official` | high | [`jsc-batch`](https://apps.fz-juelich.de/jsc/hps/jupiter/batchsystem.html) |  |
| `topology.empty-rack-positions` | 2 | racks | Booster racks 124-125 | `official` | high | [`jsc-batch`](https://apps.fz-juelich.de/jsc/hps/jupiter/batchsystem.html) |  |
| `topology.dragonfly-groups` | 25 | groups | Booster fabric | `official` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) |  |
| `topology.nodes-group` | 240 | nodes | Booster fabric group | `official` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) |  |
| `performance.hpl` | 1 | ExaFLOP/s FP64 | JUPITER Booster | `official` | high | [`jsc-tech`](https://www.fz-juelich.de/en/jsc/jupiter/tech/), [`eurohpc-systems`](https://www.eurohpc-ju.europa.eu/supercomputers/our-supercomputers_en) |  |
| `storage.exaflash-usable` | 20 | PB | JUPITER system storage | `official` | medium | [`jsc-tech`](https://www.fz-juelich.de/en/jsc/jupiter/tech/), [`jsc-buildup`](https://apps.fz-juelich.de/jsc/hps/jupiter/buildup.html) | Design capacity; ExaFLASH was still in acceptance in the latest build-up documentation. |
| `storage.exastore-raw` | 308 | PB | JUPITER system storage | `official` | high | [`jsc-tech`](https://www.fz-juelich.de/en/jsc/jupiter/tech/) |  |
| `storage.exatape` | 379 | PB | JUPITER system storage | `official` | high | [`jsc-tech`](https://www.fz-juelich.de/en/jsc/jupiter/tech/) |  |
| `allocation.node-hours` | 3500 | node-hours | project e-dev-2026d09-128 | `derived` | high | [`live-cpuquota`](evidence/live/cpu-quota.json), [`jsc-accounting`](https://apps.fz-juelich.de/jsc/hps/jupiter/accounting.html), [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) | 1,008,000 core-hours ÷ 288 cores per node. |
| `allocation.core-hours` | 1008000 | core-hours | project e-dev-2026d09-128 | `observed` | high | [`live-cpuquota`](evidence/live/cpu-quota.json) |  |
| `allocation.gpu-hour-equivalent` | 14000 | GH200-hours | project e-dev-2026d09-128 | `derived` | high | [`live-cpuquota`](evidence/live/cpu-quota.json), [`jsc-accounting`](https://apps.fz-juelich.de/jsc/hps/jupiter/accounting.html), [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) | 3,500 node-hours × 4 GH200; accounting remains node-based. |
| `accounting.minimum-node` | 1 | exclusive node | booster partition | `official` | high | [`jsc-batch`](https://apps.fz-juelich.de/jsc/hps/jupiter/batchsystem.html), [`jsc-accounting`](https://apps.fz-juelich.de/jsc/hps/jupiter/accounting.html), [`live-partition-booster`](evidence/live/partition-booster.txt) |  |
| `accounting.one-gpu` | 1 | node-hour | booster partition | `official` | high | [`jsc-accounting`](https://apps.fz-juelich.de/jsc/hps/jupiter/accounting.html), [`jsc-batch`](https://apps.fz-juelich.de/jsc/hps/jupiter/batchsystem.html) | The node is exclusive even when requesting one of four GPUs. |
| `accounting.one-gpu-allocated-gpus` | 4 | GH200 | job 1618999 | `observed` | high | [`onegpu-1618999`](evidence/probes/jupiter-one-gpu-1618999.out), [`probe-accounting`](evidence/probes/sacct-probes.txt) | ReqTRES contained one GPU, while AllocTRES contained 288 CPUs and four GH200 on the exclusive node. |
| `accounting.one-gpu-cuda-visible-devices` | 0 | environment value | job 1618999 task environment | `observed` | high | [`onegpu-1618999`](evidence/probes/jupiter-one-gpu-1618999.out), [`jsc-gpu`](https://apps.fz-juelich.de/jsc/hps/jupiter/gpu-computing.html) | The task was bound to CPU cores 0–71. CUDA runtime device count was not measured; nvidia-smi -L listed all four physical devices. |
| `partition.default-time` | 1 | hour | booster partition | `observed` | high | [`live-partition-booster`](evidence/live/partition-booster.txt) |  |
| `partition.max-time` | 12 | hours | booster QoS | `official` | high | [`jsc-batch`](https://apps.fz-juelich.de/jsc/hps/jupiter/batchsystem.html) |  |
| `partition.largebooster-state` | DOWN | state | current Slurm snapshot | `observed` | high | [`live-partition-largebooster`](evidence/live/partition-largebooster.txt) |  |
| `baseline.driver` | 595.71.05 | version | job 1618664 node jpbo-015-09 | `observed` | high | [`gpu-baseline-output`](evidence/probes/jupiter-gpu-check-1618664.out) |  |
| `baseline.cuda` | 13.2 | version | job 1618664 node jpbo-015-09 | `observed` | high | [`gpu-baseline-output`](evidence/probes/jupiter-gpu-check-1618664.out) |  |

## Calculations

| ID | Formula | Result | Scope | Type | Confidence | Sources |
| --- | --- | ---: | --- | --- | --- | --- |
| `allocation.node-hours` | 1,008,000 core-hours / 288 cores per node | 3,500 node-hours | project e-dev-2026d09-128 allocation | `derived` | high | [`live-cpuquota`](evidence/live/cpu-quota.json), [`jsc-accounting`](https://apps.fz-juelich.de/jsc/hps/jupiter/accounting.html), [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) |
| `allocation.gpu-hours` | 3,500 node-hours × 4 GH200 per node | 14,000 GH200-hours | project e-dev-2026d09-128 physical capacity equivalent | `derived` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html), [`live-cpuquota`](evidence/live/cpu-quota.json) |
| `system.gh200` | 5,884 installed nodes × 4 GH200 per node | 23,536 GH200 | installed Booster design | `derived` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) |
| `system.cores` | 5,884 installed nodes × 288 cores per node | 1,694,592 cores | installed Booster design | `derived` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) |
| `system.memory` | 5,884 nodes × (480 GB LPDDR5X + 384 GB HBM3) | 5,083,776 GB | installed nominal hardware total across separate LPDDR and HBM pools | `derived` | high | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) |
| `probes.raw-node-hours` | (19 seconds + 16 seconds) / 3,600 | 0.009722222222222222 node-hours | sacct elapsed time for jobs 1618998 and 1618999; central ledger rounding unresolved | `derived` | high | [`probe-accounting`](evidence/probes/sacct-probes.txt) |

## Storage quota claims

| Tier | Soft / hard GB | Soft / hard inodes | Scope | Type | Confidence | Sources |
| --- | ---: | ---: | --- | --- | --- | --- |
| `home` | 19.074 / 20.981 | 80,000 / 82,000 | user [redacted-user] HOME quota at snapshot | `observed` | high | [`live-user-dataquota`](evidence/live/user-data-quota.json), [`jsc-filesystems`](https://apps.fz-juelich.de/jsc/hps/jupiter/filesystems.html) |
| `project` | 20,480 / 22,528 | 4,000,000 / 4,400,000 | project e-dev-2026d09-128 quota at snapshot | `observed` | high | [`live-dataquota`](evidence/live/data-quota.json), [`jsc-filesystems`](https://apps.fz-juelich.de/jsc/hps/jupiter/filesystems.html) |
| `fscratch` | 40,960 / 45,056 | 8,000,000 / 8,800,000 | project e-dev-2026d09-128 quota at snapshot | `observed` | high | [`live-dataquota`](evidence/live/data-quota.json), [`jsc-filesystems`](https://apps.fz-juelich.de/jsc/hps/jupiter/filesystems.html) |
| `scratch` | 204,800 / 215,040 | 8,000,000 / 8,800,000 | project e-dev-2026d09-128 quota at snapshot | `observed` | high | [`live-dataquota`](evidence/live/data-quota.json), [`jsc-filesystems`](https://apps.fz-juelich.de/jsc/hps/jupiter/filesystems.html) |

## Probe register

| Probe | Job | Status | Scope | Confidence | Summary | Command provenance | Artifacts |
| --- | ---: | --- | --- | --- | --- | --- | --- |
| `baseline-four-gpu` | `1618664` | complete | job 1618664 on jpbo-015-09 | high | One node, four GH200, 15 seconds, completed successfully. The retained artifact does not contain the original requested time limit. | No retained command artifact | [baseline-job.txt](evidence/live/baseline-job.txt), [jupiter-gpu-check-1618664.out](evidence/probes/jupiter-gpu-check-1618664.out) |
| `full-node-topology` | `1618998` | complete | job 1618998 on jpbo-024-02 | high | Four ranks mapped GPU0–3 to CPU ranges 0–71, 72–143, 144–215 and 216–287; GPUs form an NV6 mesh and mlx5_0–3 map to NUMA 0–3. | Post-hoc copy of the local example added at 2026-09-02T08:52:32Z. Directives agree with retained Slurm metadata, but no submit-time byte hash exists. | [jupiter-topology-1618998.out](evidence/probes/jupiter-topology-1618998.out), [sacct-probes.txt](evidence/probes/sacct-probes.txt), [reconstructed-jupiter-topology-1618998.sbatch](evidence/probes/reconstructed-jupiter-topology-1618998.sbatch) |
| `one-gpu-accounting` | `1618999` | complete | job 1618999 on jpbo-026-13 | high | The task environment contained CUDA_VISIBLE_DEVICES=0 and cores 0–71, while Slurm AllocTRES reserved the full 288-core, four-GPU node. CUDA runtime device count was not measured. | Post-hoc copy of the local example added at 2026-09-02T08:52:32Z. Directives agree with retained Slurm metadata, but no submit-time byte hash exists. | [jupiter-one-gpu-1618999.out](evidence/probes/jupiter-one-gpu-1618999.out), [sacct-probes.txt](evidence/probes/sacct-probes.txt), [reconstructed-jupiter-one-gpu-1618999.sbatch](evidence/probes/reconstructed-jupiter-one-gpu-1618999.sbatch) |

## Source register

| Source | Publisher | Kind | Confidence | Frozen snapshot | Version | Retrieved |
| --- | --- | --- | --- | --- | --- | --- |
| [`jsc-tech`](https://www.fz-juelich.de/en/jsc/jupiter/tech/) | Juelich Supercomputing Centre | `web` | high | [jsc-tech.html](evidence/official/jsc-tech.html) | page updated 2026-06-26 | 2026-09-02 |
| [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html) | Juelich Supercomputing Centre | `web` | high | [jsc-config.html](evidence/official/jsc-config.html) | live documentation snapshot 2026-09-02 | 2026-09-02 |
| [`jsc-batch`](https://apps.fz-juelich.de/jsc/hps/jupiter/batchsystem.html) | Juelich Supercomputing Centre | `web` | high | [jsc-batch.html](evidence/official/jsc-batch.html) | live documentation snapshot 2026-09-02 | 2026-09-02 |
| [`jsc-accounting`](https://apps.fz-juelich.de/jsc/hps/jupiter/accounting.html) | Juelich Supercomputing Centre | `web` | high | [jsc-accounting.html](evidence/official/jsc-accounting.html) | live documentation snapshot 2026-09-02 | 2026-09-02 |
| [`jsc-affinity`](https://apps.fz-juelich.de/jsc/hps/jupiter/affinity.html) | Juelich Supercomputing Centre | `web` | high | [jsc-affinity.html](evidence/official/jsc-affinity.html) | live documentation snapshot 2026-09-02 | 2026-09-02 |
| [`jsc-gpu`](https://apps.fz-juelich.de/jsc/hps/jupiter/gpu-computing.html) | Juelich Supercomputing Centre | `web` | high | [jsc-gpu.html](evidence/official/jsc-gpu.html) | live documentation snapshot 2026-09-02 | 2026-09-02 |
| [`jsc-filesystems`](https://apps.fz-juelich.de/jsc/hps/jupiter/filesystems.html) | Juelich Supercomputing Centre | `web` | high | [jsc-filesystems.html](evidence/official/jsc-filesystems.html) | live documentation snapshot 2026-09-02 | 2026-09-02 |
| [`jsc-buildup`](https://apps.fz-juelich.de/jsc/hps/jupiter/buildup.html) | Juelich Supercomputing Centre | `web` | high | [jsc-buildup.html](evidence/official/jsc-buildup.html) | live documentation snapshot 2026-09-02 | 2026-09-02 |
| [`jsc-data-transfer`](https://apps.fz-juelich.de/jsc/hps/jupiter/data-transfer.html) | Juelich Supercomputing Centre | `web` | high | [jsc-data-transfer.html](evidence/official/jsc-data-transfer.html) | live documentation snapshot 2026-09-02 | 2026-09-02 |
| [`jsc-datamover`](https://apps.fz-juelich.de/jsc/hps/jupiter/datamover.html) | Juelich Supercomputing Centre | `web` | high | [jsc-datamover.html](evidence/official/jsc-datamover.html) | live documentation snapshot 2026-09-02 | 2026-09-02 |
| [`nvidia-grace`](https://docs.nvidia.com/dccpu/grace-perf-tuning-guide/) | NVIDIA | `web` | high | [nvidia-grace.html](evidence/official/nvidia-grace.html) | live documentation snapshot 2026-09-02 | 2026-09-02 |
| [`nvidia-cuda-memory`](https://docs.nvidia.com/cuda/cuda-programming-guide/02-basics/understanding-memory.html) | NVIDIA | `web` | high | [nvidia-cuda-memory.html](evidence/official/nvidia-cuda-memory.html) | live documentation snapshot 2026-09-02 | 2026-09-02 |
| [`nvidia-nccl`](https://docs.nvidia.com/deeplearning/nccl/user-guide/docs/troubleshooting/performance_and_tuning.html) | NVIDIA | `web` | high | [nvidia-nccl.html](evidence/official/nvidia-nccl.html) | live documentation snapshot 2026-09-02 | 2026-09-02 |
| [`eurohpc-systems`](https://www.eurohpc-ju.europa.eu/supercomputers/our-supercomputers_en) | EuroHPC Joint Undertaking | `web` | high | [eurohpc-systems.html](evidence/official/eurohpc-systems.html) | page retrieved 2026-09-02 | 2026-09-02 |
| [`eviden-xh3000`](https://eviden.com/wp-content/uploads/2024/10/Eviden-brochure-BullSequanaXH3000-HPC.pdf) | Eviden | `web` | medium | [eviden-xh3000.pdf](evidence/official/eviden-xh3000.pdf) | brochure 2024 | 2026-09-02 |
| [`live-snapshot`](evidence/live/manifest.txt) | U-LM observed evidence | `live` | high | n/a | snapshot 2026-09-02T00:59:31Z | 2026-09-02 |
| [`live-sinfo`](evidence/live/sinfo.txt) | U-LM observed evidence | `live` | high | n/a | snapshot 2026-09-02T00:59:31Z | 2026-09-02 |
| [`live-partition-booster`](evidence/live/partition-booster.txt) | U-LM observed evidence | `live` | high | n/a | snapshot 2026-09-02T00:59:31Z | 2026-09-02 |
| [`live-partition-largebooster`](evidence/live/partition-largebooster.txt) | U-LM observed evidence | `live` | high | n/a | snapshot 2026-09-02T00:59:31Z | 2026-09-02 |
| [`live-cpuquota`](evidence/live/cpu-quota.json) | U-LM observed evidence | `live` | high | n/a | snapshot 2026-09-02T00:59:31Z | 2026-09-02 |
| [`live-dataquota`](evidence/live/data-quota.json) | U-LM observed evidence | `live` | high | n/a | quota updated 2026-09-02T01:23:16 local service time | 2026-09-02 |
| [`live-user-dataquota`](evidence/live/user-data-quota.json) | U-LM observed evidence | `live` | high | n/a | quota updated 2026-09-02T01:20:00 local service time | 2026-09-02 |
| [`baseline-1618664`](evidence/live/baseline-job.txt) | U-LM observed evidence | `artifact` | high | n/a | Slurm job 1618664 | 2026-09-02 |
| [`gpu-baseline-output`](evidence/probes/jupiter-gpu-check-1618664.out) | U-LM observed evidence | `artifact` | high | n/a | Slurm job 1618664 | 2026-09-02 |
| [`topology-1618998`](evidence/probes/jupiter-topology-1618998.out) | U-LM observed evidence | `artifact` | high | n/a | Slurm job 1618998 | 2026-09-02 |
| [`onegpu-1618999`](evidence/probes/jupiter-one-gpu-1618999.out) | U-LM observed evidence | `artifact` | high | n/a | Slurm job 1618999 | 2026-09-02 |
| [`probe-accounting`](evidence/probes/sacct-probes.txt) | U-LM observed evidence | `artifact` | high | n/a | Slurm jobs 1618998 and 1618999 | 2026-09-02 |
| [`probe-cpuquota-after`](evidence/probes/cpu-quota-after.json) | U-LM observed evidence | `artifact` | high | n/a | post-probe snapshot 2026-09-02T01:01Z | 2026-09-02 |

## Conflicts and unresolved items

| ID | Status | Question | Resolution | Sources |
| --- | --- | --- | --- | --- |
| `cnvlink-bandwidth` | open | Is CPU cNVLink bandwidth 100 GB/s bidirectional or 100 GB/s per direction in the production node? | Retain both source wordings and request an as-built clarification from JSC. | [`jsc-config`](https://apps.fz-juelich.de/jsc/hps/jupiter/configuration.html), [`jsc-tech`](https://www.fz-juelich.de/en/jsc/jupiter/tech/) |
| `slurm-realmemory` | open | How exactly does Slurm derive RealMemory=878535M from LPDDR5X and HBM NUMA domains? | Job 1618998 establishes numerical equality: populated CPU and HBM domains total 899,620,736 kB = 878,535.875 MiB, whose integer floor is 878535. The evidence does not establish whether Slurm derived or was explicitly configured with this value. | [`topology-1618998`](evidence/probes/jupiter-topology-1618998.out), [`live-partition-booster`](evidence/live/partition-booster.txt) |
| `accounting-rounding` | open | What is the minimum rounding unit for very short jobs in central jutil accounting? | Compare sacct elapsed time with jutil after the next accounting refresh. | [`jsc-accounting`](https://apps.fz-juelich.de/jsc/hps/jupiter/accounting.html), [`probe-accounting`](evidence/probes/sacct-probes.txt), [`probe-cpuquota-after`](evidence/probes/cpu-quota-after.json) |
| `largebooster-access` | deferred | What process enables largebooster for this Development allocation? | Do not use while the partition is DOWN; ask JSC if a future campaign specifically requires that partition. | [`jsc-batch`](https://apps.fz-juelich.de/jsc/hps/jupiter/batchsystem.html), [`live-partition-largebooster`](evidence/live/partition-largebooster.txt) |
| `project-retention` | open | How long is PROJECT retained after 2027-02-28? | Confirm with JSC before the allocation end and export durable artifacts early. | [`jsc-filesystems`](https://apps.fz-juelich.de/jsc/hps/jupiter/filesystems.html), [`live-dataquota`](evidence/live/data-quota.json) |
| `one-gpu-runtime-visibility` | open | How many CUDA devices does the runtime enumerate inside the current one-GPU srun task? | Run cudaGetDeviceCount or a framework runtime probe before relying on one-task visibility; job 1618999 measured only CUDA_VISIBLE_DEVICES and physical nvidia-smi output. | [`jsc-gpu`](https://apps.fz-juelich.de/jsc/hps/jupiter/gpu-computing.html), [`onegpu-1618999`](evidence/probes/jupiter-one-gpu-1618999.out) |
| `memory-pool-headroom` | open | What per-pool LPDDR/HBM headroom and memory-cgroup behavior are safe for production workloads? | Budget LPDDR and each HBM pool separately, monitor placement and validate memory pressure in a bounded Slurm job before large campaigns. | [`nvidia-grace`](https://docs.nvidia.com/dccpu/grace-perf-tuning-guide/), [`nvidia-cuda-memory`](https://docs.nvidia.com/cuda/cuda-programming-guide/02-basics/understanding-memory.html), [`topology-1618998`](evidence/probes/jupiter-topology-1618998.out) |
| `blade-packaging` | open | What is the as-built compute-node-to-blade mapping inside a JUPITER Booster rack? | JSC documents 48 compute nodes per full rack and Eviden documents blade-based XH3000 packaging, but the frozen sources do not establish a production node-to-blade ratio. Do not publish a blade count without JSC confirmation. | [`jsc-batch`](https://apps.fz-juelich.de/jsc/hps/jupiter/batchsystem.html), [`eviden-xh3000`](https://eviden.com/wp-content/uploads/2024/10/Eviden-brochure-BullSequanaXH3000-HPC.pdf) |

Additional source tensions:

- JSC pages use both 500 and 512 GB/s for Grace LPDDR bandwidth. The current configuration value 512 GB/s is retained.
- The batch table presents a standard node as 480 GiB. Live `RealMemory=878535M` numerically equals the integer-MiB floor of populated LPDDR and HBM domains, without proving how Slurm derived or configured it.
- Build-up documentation says ExaFLASH remains in acceptance, while the project already has an observed `FSCRATCH` quota. Mount availability must be checked operationally.
- The exact wording of CPU cNVLink directionality differs across summaries; no throughput calculation depends on it.

## Integrity

Official snapshots and raw bundles are covered by [`evidence/official/SHA256SUMS`](evidence/official/SHA256SUMS), [`evidence/live/SHA256SUMS`](evidence/live/SHA256SUMS) and [`evidence/probes/SHA256SUMS`](evidence/probes/SHA256SUMS). Regenerate checksums only after intentionally refreshing evidence.
