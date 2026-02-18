#!/usr/bin/env bash
# Lab 2 Supplement (fMRIPrep): run preprocessing for ONE participant
#
# What this script does
#   - Loads the fMRIPrep module (no Docker pulls; uses the module-provided setup)
#   - Runs fMRIPrep on the class BIDS dataset (~/ds003745) for a single subject
#   - Writes ALL outputs to ~/Lab_2/ (so you do not modify the BIDS dataset)
#   - Produces an HTML report + preprocessed BOLD + confounds you can compare to FEAT
#
# Typical usage
#   bash fmriprep_lab2.sh 104
#   bash fmriprep_lab2.sh sub-104
#
# Optional overrides (no editing required)
#   FMRIPREP_VERSION=25.1.3 NTHREADS=6 MEM_MB=20000 bash fmriprep_lab2.sh 104
#
# Requirements
#   - BIDS dataset:        ~/ds003745
#   - FreeSurfer license: ~/.license  (required even if we skip recon-all)
#
# Notes for this class
#   - We use --fs-no-reconall to keep runtime manageable.
#   - fMRIPrep writes a lot of intermediate files. The work directory can be big.
#     If you need space later, you can delete: ~/Lab_2/fmriprep_work

set -euo pipefail

###############################################################################
# 0) Participant label handling
###############################################################################
if [[ $# -lt 1 ]]; then
  echo "Usage: bash $0 104   (or: bash $0 sub-104)"
  exit 1
fi

# Accept "104" or "sub-104" and normalize to "104"
SUB="${1#sub-}"
if ! [[ "$SUB" =~ ^[0-9]+$ ]]; then
  echo "ERROR: Participant label should be numeric (e.g., 104 or sub-104). Got: $1"
  exit 2
fi

###############################################################################
# 1) Paths and resources (safe defaults for lab machines)
###############################################################################
BIDS_DIR="${BIDS_DIR:-$HOME/ds003745}"

# Keep outputs OUTSIDE the dataset directory (important for class / reproducibility)
OUT_DIR="${OUT_DIR:-$HOME/Lab_2/fmriprep_out}"
WORK_DIR="${WORK_DIR:-$HOME/Lab_2/fmriprep_work}"

# FreeSurfer license file (required by fMRIPrep; it will error without it)
FS_LICENSE="${FS_LICENSE:-$HOME/.license}"

# Resource knobs (can be overridden via environment variables)
FMRIPREP_VERSION="${FMRIPREP_VERSION:-25.1.3}"
NTHREADS="${NTHREADS:-12}"
OMP_NTHREADS="${OMP_NTHREADS:-2}"
MEM_MB="${MEM_MB:-30000}"

###############################################################################
# 2) Quick checks (fail early with useful messages)
###############################################################################
echo "== fMRIPrep (Lab 2 supplement) =="
echo "  Subject:           $SUB"
echo "  BIDS:              $BIDS_DIR"
echo "  OUT:               $OUT_DIR"
echo "  WORK:              $WORK_DIR"
echo "  FreeSurfer license:$FS_LICENSE"
echo "  fMRIPrep module:   fmriprep/$FMRIPREP_VERSION"
echo "  NTHREADS:          $NTHREADS"
echo "  OMP_NTHREADS:      $OMP_NTHREADS"
echo "  MEM_MB:            $MEM_MB"
echo

# Dataset sanity checks
if [[ ! -d "$BIDS_DIR" ]]; then
  echo "ERROR: BIDS dataset not found at: $BIDS_DIR"
  echo "       (Expected ~/ds003745 for this class)"
  exit 3
fi

if [[ ! -d "$BIDS_DIR/sub-$SUB" ]]; then
  echo "ERROR: Subject folder not found: $BIDS_DIR/sub-$SUB"
  exit 4
fi

if [[ ! -f "$FS_LICENSE" ]]; then
  echo "ERROR: FreeSurfer license file not found at: $FS_LICENSE"
  echo "       Ask the instructor/TA where your license file should live."
  exit 5
fi

# Create output/work directories (safe; does nothing if they already exist)
mkdir -p "$OUT_DIR" "$WORK_DIR"

###############################################################################
# 3) Load the fMRIPrep module (THIS is the key change)
###############################################################################
# Neurodesk typically provides 'ml' (Lmod) for module loading.
# If you opened a terminal that doesn't have modules, open the "FSL terminal"
# or another module-enabled terminal in Neurodesk.
if command -v ml >/dev/null 2>&1; then
  ml fmriprep/"$FMRIPREP_VERSION"
else
  echo "ERROR: 'ml' command not found (module system unavailable in this shell)."
  echo "Try opening the module-enabled terminal in Neurodesk and rerun:"
  echo "  ml fmriprep/$FMRIPREP_VERSION"
  echo "  bash $0 $1"
  exit 6
fi

# Confirm fmriprep is now on PATH
if ! command -v fmriprep >/dev/null 2>&1; then
  echo "ERROR: fmriprep not found on PATH after loading the module."
  echo "Check that the module name/version exists: fmriprep/$FMRIPREP_VERSION"
  exit 7
fi

echo "fMRIPrep executable:"
which fmriprep
echo

###############################################################################
# 4) Run fMRIPrep
###############################################################################
# The command is split across lines for readability.
# If you are curious about any flag, run: fmriprep --help
#
# IMPORTANT:
#   - We do not edit the dataset in-place.
#   - The output is written to OUT_DIR in BIDS-derivatives format.
#
# Common useful outputs after the run:
#   - HTML report: OUT_DIR/fmriprep/sub-<ID>.html
#   - Preproc BOLD: OUT_DIR/fmriprep/sub-<ID>/func/*desc-preproc_bold.nii.gz
#   - Confounds: OUT_DIR/fmriprep/sub-<ID>/func/*desc-confounds_timeseries.tsv
#
# If you want MNI outputs, include an MNI space in --output-spaces (we do).
# 'res-2' keeps file sizes reasonable for a lab.

set -x
fmriprep \
  "$BIDS_DIR" \
  "$OUT_DIR" \
  participant \
  --participant-label "$SUB" \
  --work-dir "$WORK_DIR" \
  --fs-license-file "$FS_LICENSE" \
  --fs-no-reconall \
  --skip-bids-validation \
  --output-spaces MNI152NLin2009cAsym:res-2 T1w \
  --nthreads "$NTHREADS" \
  --omp-nthreads "$OMP_NTHREADS" \
  --mem_mb "$MEM_MB" \
  --stop-on-first-crash
set +x

###############################################################################
# 5) Print "where to look next" hints for students
###############################################################################
echo
echo "== Done =="
echo "HTML report:"
echo "  $OUT_DIR/fmriprep/sub-${SUB}.html"
echo
echo "Preprocessed BOLD (examples; exact filename depends on spaces/options):"
echo "  $OUT_DIR/fmriprep/sub-${SUB}/func/*desc-preproc_bold.nii.gz"
echo
echo "Confounds:"
echo "  $OUT_DIR/fmriprep/sub-${SUB}/func/*desc-confounds_timeseries.tsv"
echo
echo "Tip: open the HTML report in Firefox by pasting the full path into the address bar."
