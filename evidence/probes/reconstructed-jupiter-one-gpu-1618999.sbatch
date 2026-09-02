#!/bin/bash
#SBATCH --job-name=jp-one-gpu
#SBATCH --account=e-dev-2026d09-128
#SBATCH --partition=booster
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=72
#SBATCH --gpus=1
#SBATCH --time=00:02:00
#SBATCH --output=jupiter-one-gpu-%j.out

set -euo pipefail

date -u +%Y-%m-%dT%H:%M:%SZ
hostname
scontrol show job -o "$SLURM_JOB_ID"
srun --ntasks=1 --cpus-per-task=72 --gpus-per-task=1 --cpu-bind=verbose \
  bash -lc '
    grep Cpus_allowed_list /proc/self/status
    printf "CUDA_VISIBLE_DEVICES=%s\n" "$CUDA_VISIBLE_DEVICES"
    nvidia-smi -L
  '
