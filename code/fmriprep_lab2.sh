#!/usr/bin/env bash
# Lab 2 Supplement: fMRIPrep (minimal, module-based)
#
# Usage:
#   bash fmriprep_lab2_MINIMAL_MNI6_v2.sh 104
#   bash fmriprep_lab2_MINIMAL_MNI6_v2.sh sub-104
#
# This is intentionally minimal. It fixes the crash you saw by ensuring
# SUBJECTS_DIR points to an EXISTING directory before running fMRIPrep.

set -euo pipefail

# ---- Input ----
if [[ $# -lt 1 ]]; then
  echo "Usage: bash $0 104   (or: bash $0 sub-104)"
  exit 1
fi
SUB="${1#sub-}"

# ---- Paths (defaults match the class setup) ----
BIDS_DIR="${BIDS_DIR:-$HOME/ds003745}"
OUT_DIR="${OUT_DIR:-$HOME/Lab_2/fmriprep_out}"
WORK_DIR="${WORK_DIR:-$HOME/Lab_2/fmriprep_work}"
FS_LICENSE="${FS_LICENSE:-$HOME/.license}"

# Resource knobs (keep modest for lab machines)
NTHREADS="${NTHREADS:-8}"
OMP_NTHREADS="${OMP_NTHREADS:-2}"
MEM_MB="${MEM_MB:-20000}"

# ---- Load fMRIPrep (module-based; no container pulls) ----
ml fmriprep/25.1.3

# ---- Required directories ----
mkdir -p "$OUT_DIR" "$WORK_DIR"

# ---- Minimal checks ----
if [[ ! -d "$BIDS_DIR/sub-$SUB" ]]; then
  echo "ERROR: Could not find subject folder: $BIDS_DIR/sub-$SUB"
  exit 2
fi

if [[ ! -f "$FS_LICENSE" ]]; then
  echo "ERROR: FreeSurfer license not found at: $FS_LICENSE"
  exit 3
fi

# ---- Critical fix for the error you posted ----
# Your traceback shows fMRIPrep failing because MRICoreg (a FreeSurfer interface
# used during BOLD->T1w registration) receives a SUBJECTS_DIR that does not exist.
# We do NOT run recon-all, but this directory must still exist.
mkdir -p "$HOME/freesurfer-subjects-dir"

# Use a lab-local SUBJECTS_DIR and ensure it exists.
export SUBJECTS_DIR="$HOME/Lab_2/freesurfer_subjects"
mkdir -p "$SUBJECTS_DIR"

# ---- Run fMRIPrep ----
# Output spaces: ONLY MNI152NLin6Asym.
SUBJECTS_DIR="$SUBJECTS_DIR" \
  fmriprep \
    "$BIDS_DIR" \
    "$OUT_DIR" \
    participant \
    --participant-label "$SUB" \
    --work-dir "$WORK_DIR" \
    --fs-license-file "$FS_LICENSE" \
    --fs-no-reconall \
    --skip-bids-validation \
    --output-spaces MNI152NLin6Asym:res-2 \
    --nthreads "$NTHREADS" \
    --omp-nthreads "$OMP_NTHREADS" \
    --mem_mb "$MEM_MB"

echo
echo "Done."
echo "HTML report:"
echo "  $OUT_DIR/fmriprep/sub-${SUB}.html"
echo "Preprocessed BOLD in MNI space (example):"
echo "  $OUT_DIR/fmriprep/sub-${SUB}/func/*space-MNI152NLin6Asym*_desc-preproc_bold.nii.gz"
echo "Confounds (example):"
echo "  $OUT_DIR/fmriprep/sub-${SUB}/func/*desc-confounds_timeseries.tsv"
