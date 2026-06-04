#!/bin/bash
#SBATCH --job-name=ldm-baselines
#SBATCH --output=/d/hpc/home/sm79111/locality-in-diffusion-models/results/slurm/ldm-baselines-%A_%a.out
#SBATCH --error=/d/hpc/home/sm79111/locality-in-diffusion-models/results/slurm/ldm-baselines-%A_%a.err
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=24G
#SBATCH --gres=gpu:1
#SBATCH --partition=gpu
#SBATCH --array=0-5%3

set -euo pipefail

REPO_ROOT="/d/hpc/home/sm79111/locality-in-diffusion-models"
cd "$REPO_ROOT"
mkdir -p "$REPO_ROOT/results/slurm"

if [[ ! -f "$REPO_ROOT/.venv/bin/activate" ]]; then
  echo "Missing virtual environment activation script: $REPO_ROOT/.venv/bin/activate" >&2
  exit 1
fi

# Activate the project's virtual environment.
source "$REPO_ROOT/.venv/bin/activate"

# Make Python logs appear in Slurm output immediately.
export PYTHONUNBUFFERED=1

# Ensure src-layout imports work when running scripts from the repo root.
export PYTHONPATH="$REPO_ROOT/src${PYTHONPATH:+:$PYTHONPATH}"

# Keep BLAS/OpenMP thread usage aligned with Slurm allocation.
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"
export MKL_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"
export OPENBLAS_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"

CONFIGS=(
  "configs/pca_locality/afhq.yaml"
  "configs/pca_locality/celeba_hq.yaml"
  "configs/optimal/afhq.yaml"
  "configs/optimal/celeba_hq.yaml"
  "configs/wiener/afhq.yaml"
  "configs/wiener/celeba_hq.yaml"
)

TASK_ID="${SLURM_ARRAY_TASK_ID}"
if (( TASK_ID < 0 || TASK_ID >= ${#CONFIGS[@]} )); then
  echo "Invalid SLURM_ARRAY_TASK_ID=${TASK_ID}. Expected 0..$(( ${#CONFIGS[@]} - 1 ))." >&2
  exit 1
fi

CONFIG_PATH="${CONFIGS[$TASK_ID]}"
BASELINE="$(basename "$(dirname "$CONFIG_PATH")")"
DATASET="$(basename "$CONFIG_PATH" .yaml)"
RUN_NAME="${BASELINE}_${DATASET}_job${SLURM_JOB_ID}_task${TASK_ID}"

echo "[$(date -Iseconds)] Starting baseline=${BASELINE} dataset=${DATASET} config=${CONFIG_PATH}"
echo "[$(date -Iseconds)] Host=$(hostname) GPU=${CUDA_VISIBLE_DEVICES:-unset}"

# Force deterministic, per-task structured run directories:
# data/runs/slurm_baselines/<RUN_NAME>
srun --nodes=1 --exclusive python -u generate.py \
  --config "$CONFIG_PATH" \
  "experiment.device=cuda" \
  "experiment.name=slurm_baselines" \
  "experiment.run_name=${RUN_NAME}" \
  "experiment.append_timestamp=false"

echo "[$(date -Iseconds)] Finished baseline=${BASELINE} dataset=${DATASET}"
