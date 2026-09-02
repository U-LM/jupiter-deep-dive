# GH200 node and NUMA

Probe `1618998` ran on `jpbo-024-02` for 19 seconds with four Slurm tasks,
`72` CPU cores and one local GPU per task. Raw output:
[`jupiter-topology-1618998.out`](evidence/probes/jupiter-topology-1618998.out).

## Node inventory

| Component | Per GH200 | Per node | Evidence |
| --- | ---: | ---: | --- |
| Grace CPU | 72 Neoverse-V2 cores | 288 cores | `official`, `observed` |
| Grace LPDDR5X | 120 GB | 480 GB | `official` |
| Hopper HBM3 | 96 GB | 384 GB | `official`, `observed` |
| NVLink-C2C | 900 GB/s aggregate | 4 links | `official` |
| Grace CPU-pair cNVLink | 100 GB/s per direction | collapsed CPU-pair fabric | `official`, medium confidence |
| ConnectX-7 NDR200 | 1 local HCA | 4 HCAs | `official`, `observed` |

The label `NVIDIA GH200 120GB` printed by `nvidia-smi -L` does not mean that the
GPU has 120 GB HBM. `nvidia-smi` reported `97,871 MiB`, consistent with the
documented `96 GB HBM3`. The `120 GB` product label is Grace-side LPDDR5X.

## Locality groups

Linux enumerated 36 NUMA IDs, while eight domains had memory in this probe:
four CPU LPDDR domains and four GPU HBM domains.

| Rank | CPU cores | CPU NUMA | HBM NUMA / GPU NUMA ID | GPU | NIC | Link to other GPUs |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 0 | 0-71 | 0 | 4 | 0 | `mlx5_0`, NUMA 0 | `NV6` |
| 1 | 72-143 | 1 | 12 | 1 | `mlx5_1`, NUMA 1 | `NV6` |
| 2 | 144-215 | 2 | 20 | 2 | `mlx5_2`, NUMA 2 | `NV6` |
| 3 | 216-287 | 3 | 28 | 3 | `mlx5_3`, NUMA 3 | `NV6` |

Observed memory across populated domains:

| Domains | Raw total | Approximate GiB | Interpretation |
| --- | ---: | ---: | --- |
| CPU NUMA 0-3 | 501,161,856 kB | 477.945 | Grace LPDDR available to OS |
| HBM NUMA 4/12/20/28 | 398,458,880 kB | 380.000 | Hopper HBM exposed as memory nodes |
| Combined | 899,620,736 kB | 857.945 | 878,535.875 MiB; integer floor equals observed `RealMemory=878535M` |

The numerical match does not establish whether Slurm derived `RealMemory` from
those domains or was explicitly configured with the same integer value. LPDDR
and HBM remain separate pools with different bandwidth, placement and pressure
constraints. The node had zero swap. Production workloads must budget Grace
LPDDR and each 96 GB HBM pool separately, monitor page/device placement and keep
headroom; `RealMemory` does not promise fungible host DRAM.

## GPU topology

`nvidia-smi topo -m` reported `NV6` between every GPU pair, yielding a fully
connected four-GPU NVLink4 mesh. `NV6` means a bonded set of six physical
NVLinks to each peer; `NVLink4` is the link generation. JSC specifies `300 GB/s`
aggregate between a pair (`150 GB/s` per direction). The `OK` peer matrix came
from `nvidia-smi topo -p2p n`; `nvidia-smi nvlink --status` separately reported
18 active physical links per GPU at `26.562 GB/s` each on the sampled node.

NVLink-C2C gives coherent CPU-GPU addressing, but access cost still depends on
page placement and locality. CPU binding controls execution locality, not page
placement. CPU threads feeding GPU 0 should remain on cores 0-71; the same
mapping applies to the other three groups.

## Slurm binding

Recommended full-node launch:

```bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=72
#SBATCH --gpus-per-task=1

export SRUN_CPUS_PER_TASK="$SLURM_CPUS_PER_TASK"
srun --cpu-bind=cores python -u train.py
```

This layout follows the [JSC affinity guidance](https://apps.fz-juelich.de/jsc/hps/jupiter/affinity.html)
and was verified by probe. Use `srun`; JSC does not support `mpiexec` as the
launcher on JUPITER.

For a single process that intentionally controls all four GPUs, JSC currently
documents a visibility caveat: one-task jobs can receive only one value in
`CUDA_VISIBLE_DEVICES`. Confirm the current behavior before relying on a manual
`CUDA_VISIBLE_DEVICES=0,1,2,3` override.

## Multi-node implications

- Start with four ranks per node and one GPU per rank.
- Preserve Slurm's CPU binding before adding framework-specific pinning.
- Treat the four local HCAs as observed hardware topology, not proof of NCCL transport selection.
- Benchmark NCCL/UCX and confirm IB, GDR and rail selection at the intended node count; do not hardcode HCA names across nodes.
- Request compact placement with `--switches` only when network-bound scaling justifies queue delay.
- Treat Early Access tuning variables as experiment settings and record them with each run.
