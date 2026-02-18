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
# Optional overrides (no editing required)
#   FMRIPREP_VERSION=25.1.3 NTHREADS=6 MEM_MB=12000 bash code/fmriprep_lab2.sh 104
#
# Requirements
#   - BIDS dataset:        ~/ds003745
#   - FreeSurfer license: ~/.license
#
# Notes
#   - This script prefers running the official fMRIPrep container via Apptainer.
#     That avoids older Neurodesk images that may be disabled for security reasons.
#   - The first run may take longer because Apptainer may need to pull the container.
#   - We use --fs-no-reconall to keep runtime manageable for a lab.
#   - The work directory can be large; you may delete ~/Lab_2/fmriprep_work afterward.

set -euo pipefail

###############################################################################
# 0) Inputs + paths (edit only if your class dataset lives somewhere else)
###############################################################################
sub="${1:?Usage: $0 <SUBJECT_ID>  (e.g., 104 or sub-104)}"
sub="${sub#sub-}"   # allow either "104" or "sub-104"

BIDS_DIR="${HOME}/ds003745"
OUT_DIR="${HOME}/Lab_2/fmriprep_out"
WORK_DIR="${HOME}/Lab_2/fmriprep_work"

# FreeSurfer license MUST be here
FS_LIC="${HOME}/.license"

# fMRIPrep version to use (official Docker image tag)
FMRIPREP_VERSION="${FMRIPREP_VERSION:-25.1.3}"

# If you pre-pulled a .sif locally, the script will use it automatically.
SIF_PATH="${HOME}/Lab_2/fmriprep_${FMRIPREP_VERSION}.sif"

###############################################################################
# 1) Fail-fast checks (helps students debug quickly)
###############################################################################
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
# 2) Resource parameters (safe defaults for teaching)
###############################################################################
# You can override these without editing the script, e.g.:
#   NTHREADS=6 MEM_MB=12000 bash code/fmriprep_lab2.sh 104
NTHREADS="${NTHREADS:-12}"
OMP_NTHREADS="${OMP_NTHREADS:-1}"
MEM_MB="${MEM_MB:-30000}"

# Avoid oversubscribing CPU threads (especially if multiple jobs run on one machine)
export OMP_NUM_THREADS=1
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1

###############################################################################
# 3) Decide how to run fMRIPrep (Apptainer preferred)
###############################################################################
# Why Apptainer?
#   - Neurodesk may disable older containers for security reasons.
#   - Using the official nipreps/fmriprep:<version> container is predictable and current.
#
# What gets mounted into the container:
#   /data  -> your BIDS dataset (read-only)
#   /out   -> output directory (derivatives)
#   /work  -> scratch / intermediate files
#   license-> mounted to /opt/freesurfer/license.txt

IMAGE="docker://nipreps/fmriprep:${FMRIPREP_VERSION}"
if [[ -f "${SIF_PATH}" ]]; then
  # If you (or an instructor) pre-pulled a SIF, use it to avoid re-downloading.
  IMAGE="${SIF_PATH}"
fi

###############################################################################
# 4) Run
###############################################################################
echo "== fMRIPrep (Lab 2 supplement) =="
echo "  Subject:          ${sub}"
echo "  BIDS (host):      ${BIDS_DIR}"
echo "  OUT  (host):      ${OUT_DIR}"
echo "  WORK (host):      ${WORK_DIR}"
echo "  FreeSurfer lic:   ${FS_LIC}"
echo "  fMRIPrep version: ${FMRIPREP_VERSION}"
echo "  Apptainer image:  ${IMAGE}"
echo "  NTHREADS:         ${NTHREADS}"
echo "  OMP_NTHREADS:     ${OMP_NTHREADS}"
echo "  MEM_MB:           ${MEM_MB}"
echo ""

if command -v apptainer >/dev/null 2>&1; then
  # Optional instructor convenience: pre-pull once to create a local SIF
  #   apptainer pull "${SIF_PATH}" "docker://nipreps/fmriprep:${FMRIPREP_VERSION}"
  #
  # Then the script will automatically use ${SIF_PATH} next time.

  apptainer run --cleanenv \
    -B "${BIDS_DIR}:/data:ro" \
    -B "${OUT_DIR}:/out" \
    -B "${WORK_DIR}:/work" \
    -B "${FS_LIC}:/opt/freesurfer/license.txt:ro" \
    "${IMAGE}" \
    /data /out participant \
      --participant-label "${sub}" \
      --stop-on-first-crash \
      --fs-license-file /opt/freesurfer/license.txt \
      --fs-no-reconall \
      --output-spaces T1w MNI152NLin2009cAsym:res-2 \
      --nthreads "${NTHREADS}" \
      --omp-nthreads "${OMP_NTHREADS}" \
      --mem-mb "${MEM_MB}" \
      --notrack \
      -w /work

else
  # Fallback: if Apptainer is not available, try a local fmriprep installation.
  # (On many Neurodesk setups, this may still point to a container wrapper.)
  if ! command -v fmriprep >/dev/null 2>&1; then
    echo "ERROR: apptainer not found AND fmriprep not found on PATH." >&2
    echo "Fix: run this inside Neurodesk (which includes apptainer), or load an fmriprep module." >&2
    exit 1
  fi

  fmriprep "${BIDS_DIR}" "${OUT_DIR}" participant \
    --participant-label "${sub}" \
    --stop-on-first-crash \
    --fs-license-file "${FS_LIC}" \
    --fs-no-reconall \
    --output-spaces T1w MNI152NLin2009cAsym:res-2 \
    --nthreads "${NTHREADS}" \
    --omp-nthreads "${OMP_NTHREADS}" \
    --mem-mb "${MEM_MB}" \
    --notrack \
    -w "${WORK_DIR}"
fi

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
