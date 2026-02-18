#!/usr/bin/env bash
# Lab 2 Supplement (fMRIPrep): run preprocessing for ONE participant
#
# Purpose
#   - Run fMRIPrep on the class dataset (~/ds003745) for a single subject
#   - Write ALL outputs to ~/Lab_2/ (so you do not modify the BIDS dataset)
#   - Produce an HTML report + preprocessed BOLD + confounds you can compare to FEAT
#
# Usage
#   bash code/fmriprep_lab2.sh 104
#   bash code/fmriprep_lab2.sh sub-104
#
# Requirements
#   - BIDS dataset:        ~/ds003745
#   - FreeSurfer license: ~/.license
#       (fMRIPrep checks for a license even if you skip recon-all)
#
# Optional resource overrides (useful on slower machines)
#   NTHREADS=6 MEM_MB=12000 bash code/fmriprep_lab2.sh 104
#
# Notes
#   - This script uses --fs-no-reconall to keep runtime manageable for a lab.
#   - The work directory can be large; you may delete ~/Lab_2/fmriprep_work afterward.

set -euo pipefail

###############################################################################
# 0) Load fMRIPrep (Neurodesk-friendly)
###############################################################################
ml fmriprep/20.2.3



###############################################################################
# 1) Parse inputs + set paths
###############################################################################
sub="${1:?Usage: $0 <SUBJECT_ID>  (e.g., 104 or sub-104)}"
sub="${sub#sub-}"   # allow either "104" or "sub-104"

BIDS_DIR="${HOME}/ds003745"
OUT_DIR="${HOME}/Lab_2/fmriprep_out"
WORK_DIR="${HOME}/Lab_2/fmriprep_work"

# FreeSurfer license MUST be here
FS_LIC="${HOME}/.license"

# Quick existence checks (fail fast with helpful messages)
if [[ ! -d "${BIDS_DIR}" ]]; then
  echo "ERROR: BIDS directory not found: ${BIDS_DIR}" >&2
  exit 1
fi

if [[ ! -d "${BIDS_DIR}/sub-${sub}" ]]; then
  echo "ERROR: Subject folder not found: ${BIDS_DIR}/sub-${sub}" >&2
  echo "Check the subject ID you provided (expected something like sub-104)." >&2
  exit 1
fi

if [[ ! -r "${FS_LIC}" ]]; then
  echo "ERROR: FreeSurfer license not found/readable at: ${FS_LIC}" >&2
  echo "Fix: Save your FreeSurfer license file as ~/.license" >&2
  exit 1
fi

mkdir -p "${OUT_DIR}" "${WORK_DIR}"

###############################################################################
# 2) Set resource parameters (safe defaults for teaching)
###############################################################################
# You can override these without editing the script, e.g.:
#   NTHREADS=6 MEM_MB=12000 bash code/fmriprep_lab2.sh 104
NTHREADS="${NTHREADS:-12}"
OMP_NTHREADS="${OMP_NTHREADS:-1}"
MEM_MB="${MEM_MB:-30000}"

# Avoid oversubscribing CPU threads (especially if several jobs run on one machine)
export OMP_NUM_THREADS=1
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1

###############################################################################
# 3) Run fMRIPrep
###############################################################################
echo "== fMRIPrep (Lab 2 supplement) =="
echo "  Subject:   ${sub}"
echo "  BIDS:      ${BIDS_DIR}"
echo "  OUT:       ${OUT_DIR}"
echo "  WORK:      ${WORK_DIR}"
echo "  License:   ${FS_LIC}"
echo "  NTHREADS:  ${NTHREADS}"
echo "  MEM_MB:    ${MEM_MB}"
echo ""

# Key flags (high level):
#   participant                 : run subject-level processing
#   --fs-no-reconall            : skip FreeSurfer recon-all (faster)
#   --output-spaces ...         : ensure outputs in T1w and MNI space
#   --stop-on-first-crash       : fail fast so errors are obvious
#   --notrack                   : do not send telemetry
#
# If you encounter BIDS validation errors and need to proceed for the lab,
# you can add --skip-bids-validation here. (We leave it off by default.)

fmriprep "${BIDS_DIR}" "${OUT_DIR}" participant \
  --participant-label "${sub}" \
  --stop-on-first-crash \
  --fs-license-file "${FS_LIC}" \
  --fs-no-reconall \
  --output-spaces MNI152NLin2009cAsym \
  --nthreads "${NTHREADS}" \
  --omp-nthreads "${OMP_NTHREADS}" \
  --mem-mb "${MEM_MB}" \
  --notrack \
  -w "${WORK_DIR}"

echo ""
echo "== Done =="
echo "HTML report:"
echo "  ${OUT_DIR}/fmriprep/sub-${sub}.html"
echo ""
echo "Preprocessed BOLD (examples; exact filename depends on spaces/output options):"
echo "  ${OUT_DIR}/fmriprep/sub-${sub}/func/*desc-preproc_bold.nii.gz"
echo ""
echo "Confounds:"
echo "  ${OUT_DIR}/fmriprep/sub-${sub}/func/*desc-confounds_timeseries.tsv"
