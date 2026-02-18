#!/usr/bin/env bash
# Lab 2 Supplement: fMRIPrep (minimal, module-based)
#
# Usage:
#   bash fmriprep_lab2_MINIMAL_MNI6.sh 104
#   bash fmriprep_lab2_MINIMAL_MNI6.sh sub-104
#
# Minimal on purpose:
#   - load the fMRIPrep module
#   - run one participant
#   - write outputs to ~/Lab_2/
#
# Note on SUBJECTS_DIR (this is the bug you hit):
#   Your traceback shows fMRIPrep failing because 'subjects_dir' points to a directory that does not exist
#   (e.g., '/home/jovyan/freesurfer-subjects-dir'). Some registration utilities expect SUBJECTS_DIR to be an
#   *existing* folder. Creating it is enough.

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

# Modest defaults for lab machines (override via env vars if needed)
NTHREADS="${NTHREADS:-8}"
OMP_NTHREADS="${OMP_NTHREADS:-2}"
MEM_MB="${MEM_MB:-20000}"

# ---- Load fMRIPrep (module-based; no container pulls) ----
ml fmriprep/25.1.3

# ---- SUBJECTS_DIR fix ----
# Prefer whatever SUBJECTS_DIR the module sets, but ensure it exists.
# If it's unset, keep it contained inside the lab folder.
if [[ -z "${SUBJECTS_DIR:-}" ]]; then
  export SUBJECTS_DIR="$HOME/Lab_2/freesurfer_subjects"
fi
mkdir -p "$SUBJECTS_DIR"

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

# ---- Run fMRIPrep ----
# Output spaces: ONLY MNI152NLin6Asym (per your constraint).
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
