#!/bin/bash
#SBATCH --job-name=jp-topology
#SBATCH --account=e-dev-2026d09-128
#SBATCH --partition=booster
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=72
#SBATCH --gpus-per-task=1
#SBATCH --gpus=4
#SBATCH --threads-per-core=1
#SBATCH --time=00:05:00
#SBATCH --output=jupiter-topology-%j.out

set -uo pipefail
export SRUN_CPUS_PER_TASK="$SLURM_CPUS_PER_TASK"

section() { printf '\n===== %s =====\n' "$1"; }
run_optional() { "$@" 2>&1 || printf '[unavailable rc=%s] %s\n' "$?" "$*"; }

section IDENTITY
date -u +%Y-%m-%dT%H:%M:%SZ
hostname
printf 'job_id=%s\n' "$SLURM_JOB_ID"
run_optional scontrol show job -o "$SLURM_JOB_ID"
run_optional scontrol show node -o "$HOSTNAME"

section CPU_MEMORY
run_optional lscpu
run_optional lscpu -e=CPU,NODE,SOCKET,CORE,ONLINE
run_optional free -h
run_optional numactl -H
run_optional cat /proc/sys/kernel/numa_balancing

section GPU
run_optional nvidia-smi -L
run_optional nvidia-smi --query-gpu=index,name,memory.total,pci.bus_id,driver_version --format=csv,noheader
run_optional nvidia-smi topo -m
run_optional nvidia-smi topo -p2p n
run_optional nvidia-smi nvlink --status

section PCI_INFINIBAND
run_optional sh -lc "lspci -Dnn | grep -Ei 'NVIDIA|Mellanox'"
for device in /sys/class/infiniband/*; do
  test -e "$device" || continue
  printf '%s|bdf=%s|numa=%s\n' \
    "$(basename "$device")" \
    "$(basename "$(readlink -f "$device/device")")" \
    "$(cat "$device/device/numa_node")"
done
run_optional ibstat

section RELEVANT_NUMA_DOMAINS
for node in 0 1 2 3 4 12 20 28; do
  node_dir="/sys/devices/system/node/node$node"
  test -d "$node_dir" || continue
  printf 'node%s|cpus=%s\n' "$node" "$(cat "$node_dir/cpulist")"
  grep MemTotal "$node_dir/meminfo" || true
done

section SLURM_BINDING
srun --ntasks=4 --ntasks-per-node=4 --cpus-per-task=72 --gpus-per-task=1 \
  --cpu-bind=verbose bash -lc '
    cpus=$(awk "/Cpus_allowed_list/{print \$2}" /proc/self/status)
    printf "rank=%s|gpu=%s|cpus=%s\n" "$SLURM_PROCID" "$CUDA_VISIBLE_DEVICES" "$cpus"
    numactl --show 2>/dev/null | sed "s/^/rank=$SLURM_PROCID|/"
  '
