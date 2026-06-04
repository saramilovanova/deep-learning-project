#!/bin/bash
#SBATCH --job-name=ldm-generate-test
#SBATCH --output=/d/hpc/home/sm79111/locality-in-diffusion-models/results/slurm/generate-test-%j.out
#SBATCH --error=/d/hpc/home/sm79111/locality-in-diffusion-models/results/slurm/generate-test-%j.err
#SBATCH --time=04:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=24G
#SBATCH --gres=gpu:1
#SBATCH --partition=gpu

set -euo pipefail

REPO_ROOT="/d/hpc/home/sm79111/locality-in-diffusion-models"
cd "$REPO_ROOT"
mkdir -p "$REPO_ROOT/results/slurm"

if [[ ! -f "$REPO_ROOT/.venv/bin/activate" ]]; then
  echo "Missing virtual environment activation script: $REPO_ROOT/.venv/bin/activate" >&2
  exit 1
fi

if [[ $# -lt 1 ]]; then
  cat >&2 <<'EOF'
Usage:
  sbatch generate_test.sbatch <config-path> [config.override=value ...]

Example:
  sbatch generate_test.sbatch configs/pca_locality/celeba_hq.yaml sampling.num_samples=128 sampling.batch_size=32
EOF
  exit 1
fi

CONFIG_PATH="$1"
shift
OVERRIDES=("$@")

source "$REPO_ROOT/.venv/bin/activate"
export PYTHONUNBUFFERED=1
export PYTHONPATH="$REPO_ROOT/src${PYTHONPATH:+:$PYTHONPATH}"
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"
export MKL_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"
export OPENBLAS_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"

RUN_STAMP="$(date +%Y%m%d-%H%M%S)"
RUN_NAME="$(basename "$CONFIG_PATH" .yaml)_${SLURM_JOB_ID}_${RUN_STAMP}"

echo "[$(date -Iseconds)] Starting generate.py"
echo "[$(date -Iseconds)] Config=${CONFIG_PATH}"
echo "[$(date -Iseconds)] Overrides=${OVERRIDES[*]:-<none>}"
echo "[$(date -Iseconds)] Host=$(hostname) GPU=${CUDA_VISIBLE_DEVICES:-unset}"

srun --nodes=1 --exclusive python -u generate.py \
  --config "$CONFIG_PATH" \
  experiment.device=cuda \
  experiment.name=slurm_generate \
  experiment.run_name="$RUN_NAME" \
  experiment.append_timestamp=false \
  "${OVERRIDES[@]}"

echo "[$(date -Iseconds)] Finished generate.py"
