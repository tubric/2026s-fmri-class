# Lab 2 (Supplement): Preprocessing with fMRIPrep

This supplement repeats the central idea of Lab 2—**preprocessing is a set of concrete operations with visible consequences**—but does it using **fMRIPrep** rather than FEAT.

You are not being graded on flags. You are being graded on whether you (a) ran the pipeline and (b) looked at the outputs closely enough to make a simple comparison.

---

## Learning objectives

By the end of this supplement, you will be able to:

- Run fMRIPrep for **one participant** from the command line.
- Locate the most useful outputs:
  - the **HTML report**
  - a **preprocessed BOLD** file
  - the **confounds** table
- Make a brief, evidence-based comparison to what you did in FEAT.

---

## Before you begin

### 1) Confirm the dataset exists

In a terminal:

```bash
ls ~/ds003745
ls ~/ds003745/sub-104/func
```

You should see the BOLD run you used in Lab 2:
`sub-104_task-trust_run-01_bold.nii.gz`

### 2) Make sure you can run both fMRIPrep and FSLEyes

Depending on how you opened Neurodesk, tools may already be available. If you need modules, try:

```bash
ml fmriprep/25.1.3
ml fsl
which fmriprep
which fsleyes
```

If `which fmriprep` and `which fsleyes` both print paths, you are ready.

### 3) FreeSurfer license file (required)

Even when you skip FreeSurfer reconstruction, fMRIPrep expects a license file.

- Put your FreeSurfer license at: `~/.license`

Verify it exists:

```bash
ls -l ~/.license
```

---

## 1) Create an output location for this supplement

To keep your BIDS dataset clean (read-only in spirit), write outputs to your Lab 2 folder:

```bash
mkdir -p ~/Lab_2/fmriprep_out
mkdir -p ~/Lab_2/fmriprep_work
```

- `fmriprep_out` stores outputs you keep.
- `fmriprep_work` stores temporary working files (often large). You may delete it after you finish.

---

## 2) Run fMRIPrep (one participant)

### Option A (recommended): Use the wrapper script

Run:

```bash
bash code/fmriprep_lab2.sh 104
```

> fMRIPrep expects the participant label **without** the `sub-` prefix, but the script accepts either `104` or `sub-104`.

### Option B: Run directly (same idea, no script)

```bash
# Load fMRIPrep
ml fmriprep/25.1.3

# Create a SUBJECTS_DIR (required for some BOLD↔T1 registration steps)
mkdir -p ~/Lab_2/freesurfer_subjects
export SUBJECTS_DIR=~/Lab_2/freesurfer_subjects

fmriprep ~/ds003745 ~/Lab_2/fmriprep_out participant \
  --participant-label 104 \
  --fs-license-file ~/.license \
  --fs-no-reconall \
  --skip-bids-validation \
  --output-spaces MNI152NLin6Asym \
  --nthreads 8 --omp-nthreads 2 --mem_mb 20000 \
  --work-dir ~/Lab_2/fmriprep_work
```

If you get memory errors, reduce resources:

```bash
# Replace the resource line above with, for example:
--nthreads 4 --omp-nthreads 1 --mem_mb 12000
```

---

## 3) What to look at after it finishes

### A) HTML report (your first QC stop)

Open:

- `~/Lab_2/fmriprep_out/fmriprep/sub-104.html`

Find a panel that shows **alignment/registration** (functional→structural or structural→standard). You will use this for your submission.

### B) Preprocessed BOLD

List the candidate outputs:

```bash
ls ~/Lab_2/fmriprep_out/fmriprep/sub-104/func/*space-MNI152NLin6Asym*_desc-preproc_bold.nii.gz
```

Pick one of the `desc-preproc_bold` files (MNI space only in this lab) and compare it to the raw BOLD run from the BIDS folder:

- Raw: `~/ds003745/sub-104/func/sub-104_task-trust_run-01_bold.nii.gz`
- fMRIPrep: `~/Lab_2/fmriprep_out/fmriprep/sub-104/func/...desc-preproc_bold.nii.gz`

Open both in FSLEyes:

```bash
fsleyes \
  ~/ds003745/sub-104/func/sub-104_task-trust_run-01_bold.nii.gz \
  ~/Lab_2/fmriprep_out/fmriprep/sub-104/func/<YOUR_PREPROC_FILE>.nii.gz &
```

### C) (Optional) Confounds file

In the same directory you will also find a confounds table:

- `*desc-confounds_timeseries.tsv`

This is where motion estimates and related nuisance signals live.

---

## 4) A minimal comparison to FEAT

Pick **one** FEAT run from Lab 2 (e.g., your MCFLIRT-only output) and locate the main file you inspected there:

- `~/Lab_2/OUTPUT/<YOUR_FEAT_RUN>.feat/filtered_func_data.nii.gz`

You will make a brief comparison between:

- FEAT: `filtered_func_data.nii.gz`
- fMRIPrep: `desc-preproc_bold.nii.gz`

---

## What to submit (keep it simple)

Submit **three screenshots** plus **four short bullets**. The goal is to show (a) you ran the pipeline and (b) you *looked* closely enough to compare it to FEAT.

### Screenshots

1) **fMRIPrep report: registration / normalization**  
   In `sub-104.html`, take **one** screenshot that shows alignment for:
   - BOLD reference → T1w (registration), and/or
   - T1w → MNI (normalization)

2) **FEAT report: registration**  
   From your FEAT run, take **one** screenshot from `report_reg.html` that shows the functional→structural and structural→standard alignment.

3) **Data view (FSLEyes)**  
   A screenshot from FSLEyes showing **either**:
   - raw BOLD vs fMRIPrep preprocessed BOLD, **or**
   - FEAT preprocessed BOLD vs fMRIPrep preprocessed BOLD  
   (Side-by-side or toggling is fine.)

### Bullets (4 total)

- **Registration/normalization comparison (1–2 sentences):** Which pipeline looked better *for this subject* (FEAT vs fMRIPrep), and what specific visual evidence did you use (e.g., brain edges, ventricles, midline alignment)?
- **Similarities (1 sentence):** One preprocessing goal or step that is clearly common to both pipelines.
- **Differences (1 sentence):** One output, option, or design choice that differs between pipelines (e.g., confounds outputs, standard spaces, default operations).
- **Takeaway (1 sentence):** If you were preprocessing data for a paper, what is one practical tradeoff you’d consider when choosing FEAT vs fMRIPrep?

That’s it.


---

---


## Troubleshooting checklist (quick)

- **`ml: command not found`**
  - Open a module-enabled terminal in Neurodesk (the same kind you used for FSL), then run:
    ```bash
    ml fmriprep/25.1.3
    ```
- **FreeSurfer `SUBJECTS_DIR` error (like the one we saw in class)**
  - Create the directory and rerun:
    ```bash
    mkdir -p ~/Lab_2/freesurfer_subjects
    export SUBJECTS_DIR=~/Lab_2/freesurfer_subjects
    ```
  - Or just use the wrapper script, which sets this automatically.
- **FreeSurfer license error**
  - Confirm the license exists:
    ```bash
    ls -l ~/.license
    ```
- **Runs out of memory / crashes**
  - Reduce resources:
    ```bash
    NTHREADS=4 OMP_NTHREADS=1 MEM_MB=12000 bash fmriprep_lab2.sh 104
    ```
- **Can’t find the report**
  - Look here:
    - `~/Lab_2/fmriprep_out/fmriprep/sub-104.html`
