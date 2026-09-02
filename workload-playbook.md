# Workload playbook

## Baseline Slurm layout

Use one rank for each GH200 locality group:

```bash
#!/bin/bash
#SBATCH --account=e-dev-2026d09-128
#SBATCH --partition=booster
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=72
#SBATCH --gpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --output=%x-%j.out

set -euo pipefail
export SRUN_CPUS_PER_TASK="$SLURM_CPUS_PER_TASK"
srun --cpu-bind=cores python -u workload.py
```

Use `srun` for every compute step. Login nodes are limited to submission,
monitoring, lightweight Data Mover control commands and small-log inspection.

## Scenario matrix

| Scenario | Layout | Allocation efficiency | Guidance |
| --- | --- | --- | --- |
| One-GPU correctness debug | 1 node, 1 task, 72 cores, 1 GPU, <=2 min | 25% GPU; full node charged | Conditional, keep very short |
| Four independent workers | 1 node, 4 tasks, 72 cores + 1 GPU each | 100% physical GPU packing | Preferred |
| Single-node distributed | 1 node, 4 ranks, NCCL over NVLink | full node | Preferred |
| Multi-node DDP/NCCL | N nodes, 4 ranks/node | `4N` active GPUs | Allocation skeleton; add framework launcher and validate transport |
| Tokenizer transfer | CPU/data stage, then 4-GPU adaptation | workload-dependent | Split preprocessing and training jobs |
| Distillation/generation | four workers/node or distributed engine | full node target | Checkpoint and deduplicate incrementally |
| Benchmark serving | 4-GPU server or four replicas plus reserved same-allocation client cores | depends on parallel strategy | Account explicitly for any second node |

## Pack four independent processes

```bash
status_dir=$(mktemp -d "${TMPDIR:-/tmp}/packed-${SLURM_JOB_ID}.XXXXXX")
pids=()
shards=(0 1 2 3)
terminate_children() {
  local pid
  for pid in "${pids[@]}"; do
    if [[ -n "$pid" ]]; then
      kill "$pid" 2>/dev/null || true
    fi
  done
  wait || true
}
trap 'terminate_children; rm -rf "$status_dir"; exit 130' INT TERM

for shard in "${shards[@]}"; do
  (
    step_pid=
    stop_step() {
      if [[ -n "$step_pid" ]]; then
        kill "$step_pid" 2>/dev/null || true
        wait "$step_pid" 2>/dev/null || true
      fi
      exit 143
    }
    trap stop_step INT TERM
    set +e
    srun --exclusive -n1 -c72 --gres=gpu:1 --cpu-bind=cores \
      python worker.py --shard "$shard" \
      >"worker-${shard}-${SLURM_JOB_ID}.out" 2>&1 &
    step_pid=$!
    wait "$step_pid"
    rc=$?
    printf '%s\n' "$rc" >"$status_dir/$shard.tmp"
    mv "$status_dir/$shard.tmp" "$status_dir/$shard.done"
    exit "$rc"
  ) &
  pids+=("$!")
done

remaining=${#shards[@]}
while ((remaining)); do
  found=0
  for index in "${!shards[@]}"; do
    shard=${shards[$index]}
    [[ -n "$shard" ]] || continue
    result="$status_dir/$shard.done"
    [[ -f "$result" ]] || continue
    found=1
    rc=$(<"$result")
    wait "${pids[$index]}" 2>/dev/null || true
    pids[$index]=""
    shards[$index]=""
    remaining=$((remaining - 1))
    if ((rc != 0)); then
      terminate_children
      rm -rf "$status_dir"
      exit "$rc"
    fi
  done
  if ((remaining && !found)); then
    sleep 0.2
  fi
done
rm -rf "$status_dir"
trap - INT TERM
```

This pattern keeps four workloads in one allocation and publishes each result
through an atomic status file. The parent observes completion order and terminates
surviving Slurm steps immediately after the first nonzero result. Four separate
`sbatch` jobs cannot share the same node under current exclusive scheduling.

## Multi-node allocation skeleton

```bash
#SBATCH --nodes=8
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=72
#SBATCH --gpus-per-task=1
#SBATCH --time=06:00:00

export SRUN_CPUS_PER_TASK="$SLURM_CPUS_PER_TASK"
export NCCL_DEBUG=WARN
srun --cpu-bind=cores python -u train.py
```

This block allocates and binds ranks. A complete DDP launch additionally needs
the framework's rendezvous, `RANK`/`WORLD_SIZE` mapping, master endpoint, module/PMIx
initialization, checkpoint/failure handling and restart policy. Before a long
campaign, use `nccl-tests` and framework diagnostics to confirm IB, GDR, HCA and
rail selection, then run a short representative step at 1, 2, 4 and 8 nodes.
Record samples/second, tokens/second, step time, communication fraction and
node-hours per useful training token. Use `NCCL_DEBUG=INFO` only during diagnosis
because verbose logs can become large.

## Project workflows

### Tokenizer transfer

1. Place canonical input manifests in `PROJECT`.
2. Use JUDAC for external transfer. Stage ExaSTORE to ExaFLASH with a JSC `nd copy` Data Mover task through a lightweight bridge command, then verify its task ID before allocation.
3. Expand and tokenize four independent shards with `4 × 72` CPU-core tasks, or use another measured layout that occupies all 288 paid cores.
4. Validate shard hashes and token statistics before GPU adaptation.
5. Run four ranks per node and save milestone adapters/checkpoints to scratch.
6. Promote reproducible checkpoints and tokenizer assets to `PROJECT`.

### On-policy and self-distillation

1. Keep self-distillation and strict on-policy pipelines separate in manifests and queues.
2. Tag every batch with policy/teacher revision, checkpoint hash, tokenizer revision, prompt/template revision, input shard identity and checksum, sample or RNG seed, scorer/reward/reference revision where applicable, and generation configuration.
3. For on-policy data, define maximum policy staleness, backpressure and learner-consumption rules before generation starts.
4. Pack four generation workers per node when replicas fit one 96 GB HBM device.
5. Use multi-GPU inference only when model memory or throughput measurements justify it.
6. Write raw generations to `SCRATCH`; record each output shard checksum, then validate and deduplicate in separate Slurm jobs.
7. Track accepted tokens per node-hour, not raw generated tokens alone.

### Benchmark serving

1. Confirm CUDA runtime device count for the selected one-process or multi-rank server layout.
2. Prefer one batch allocation that reserves CPU cores for a CPU-only client `srun --exclusive` step alongside the GPU server steps.
3. Start the same-allocation client only after readiness is confirmed. When the server consumes all node CPU resources, use an explicitly charged second Booster node or a JSC-supported external client system.
4. Never submit a separate Booster client job without including its full-node charge in the campaign estimate.
5. Stop the allocation immediately after the final request.
6. Persist latency distributions, throughput, model revision and job IDs in `PROJECT`.

## Monitoring

```bash
eurohpc-bridge squeue
eurohpc-bridge sacct JOB_ID
eurohpc-bridge run -- jutil project cpuquota -p e-dev-2026d09-128 -o json
eurohpc-bridge run -- jutil project dataquota -p e-dev-2026d09-128 -U GB -o json
eurohpc-bridge run -- nd task status TASK_ID
```

Inside a running job, use bounded sampling of `nvidia-smi`, application metrics
and framework profiler output. Avoid continuous high-frequency telemetry that
distorts I/O or generates large logs.

## Campaign checklist

- Confirm `booster` state and current JSC known issues.
- Verify input data and container/module availability before allocation.
- Request the shortest realistic wall time and full GPU packing.
- Write checkpoints to scratch and promote durable milestones.
- Capture `sacct -X`, exact command, environment and source revision.
- Compare consumed node-hours with useful tokens or benchmark samples.
