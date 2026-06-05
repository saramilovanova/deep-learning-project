# Locality in Diffusion Models

This repository contains the code, configurations, and analysis notebooks for the *Deep Learning project* investigating **locality properties in diffusion models**.

The project includes implementations and experiments involving:

* Optimal diffusion models
* PCA-locality models
* Wiener models
* Baseline U-Net diffusion models

To keep the GitHub repository lightweight, large datasets, trained models, experiment outputs, and cluster logs are stored externally.

---

# Full Project Archive

The complete project archive (~10 GB) is available on Hugging Face:

**Hugging Face Repository:**
https://huggingface.co/saramil/deep-learning-project-data

The archive contains:

* Datasets
* Trained model checkpoints
* Experiment outputs
* SLURM logs
* Generated samples
* Intermediate artifacts

Together with the code in this repository, these files provide everything required to reproduce the experimental pipeline and reported results.

---

# Repository Structure

```text
configs/                        Experiment configurations (YAML)
notebooks/                      Analysis and visualization notebooks
src/                            Core library code (models, data, utilities)

download_baseline_weights.py    Download baseline model weights
generate.py                     Sampling and image generation script

generate_test.sbatch            SLURM generation job for a test experiment
run_all_baselines_array.sbatch  Baseline experiment array job
run_all_baselines.sh            Baseline experiment launcher
run_nearest_dataset_array.sbatch Nearest-dataset test experiment array job

environment.yml                 Conda environment
environment-gpu.yml             GPU-specific Conda environment
requirements.txt                Python dependencies
pyproject.toml                  Project metadata
```

The following directories are intentionally excluded from version control because of their size:

```text
data/
models/
runs/
wandb/
datasets/
```

These files are available in the external archive linked above.

---

# Installation

## Using Conda

```bash
conda env create -f environment.yml
conda activate locality
```

## Using pip

```bash
pip install -r requirements.txt
```

---

# Running Experiments

Example configuration:

```bash
python generate.py --config configs/optimal/cifar10.yaml
```

Additional experiment launchers and SLURM scripts are provided for running larger experiment batches on HPC clusters.

---

# Analysis Notebooks

The `notebooks/` directory contains Jupyter notebooks for:

* Visualizing diffusion trajectories
* Inspecting generated samples
* Comparing locality metrics
* Summarizing experimental results

