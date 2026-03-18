# Troubleshooting Guide: Linux, Neurodesk, FEAT, and fMRIPrep

This guide collects common problems that have come up in labs, discussion-board posts, and support materials for the course. Use it when something is not working, when you cannot find an output, or when the command line feels more confusing than it should.

A good troubleshooting habit is to slow down and identify **where** the problem actually is:

1. Is this a **Linux/navigation** problem?
2. Is this a **wrong terminal / wrong environment** problem?
3. Is this a **file path / output location** problem?
4. Is this a **FEAT setup** problem?
5. Is this a **pipeline-specific** problem (for example, fMRIPrep)?

Most issues in this course fall into one of those buckets.

---

## Table of contents

- [1. Start here: the fastest troubleshooting checks](#1-start-here-the-fastest-troubleshooting-checks)
- [2. Linux navigation basics](#2-linux-navigation-basics)
  - [2.1 Where am I?](#21-where-am-i)
  - [2.2 What is in this folder?](#22-what-is-in-this-folder)
  - [2.3 How do I move around?](#23-how-do-i-move-around)
  - [2.4 Absolute vs relative paths](#24-absolute-vs-relative-paths)
  - [2.5 Create folders before writing output](#25-create-folders-before-writing-output)
  - [2.6 Find a file when you are lost](#26-find-a-file-when-you-are-lost)
- [3. Base terminal and loading FSL with `ml`](#3-base-terminal-and-loading-fsl-with-ml)
- [4. DataLad and downloaded files](#4-datalad-and-downloaded-files)
- [5. I cannot find my output](#5-i-cannot-find-my-output)
- [6. FEAT troubleshooting](#6-feat-troubleshooting)
  - [6.1 FEAT output naming and folder structure](#61-feat-output-naming-and-folder-structure)
  - [6.2 The Post-stats tab is blank](#62-the-post-stats-tab-is-blank)
  - [6.3 My structural image does not look skull-stripped in the report](#63-my-structural-image-does-not-look-skull-stripped-in-the-report)
  - [6.4 My model setup looks wrong or FEAT will not proceed](#64-my-model-setup-looks-wrong-or-feat-will-not-proceed)
- [7. fMRIPrep troubleshooting](#7-fmriprep-troubleshooting)
  - [7.1 FreeSurfer license problems](#71-freesurfer-license-problems)
  - [7.2 SUBJECTS_DIR problems](#72-subjects_dir-problems)
  - [7.3 Memory / resource problems](#73-memory--resource-problems)
  - [7.4 I cannot find the report or output files](#74-i-cannot-find-the-report-or-output-files)
  - [7.5 HTML report does not open correctly](#75-html-report-does-not-open-correctly)
- [8. fsleyes troubleshooting](#8-fsleyes-troubleshooting)
- [9. Common command-line mistakes](#9-common-command-line-mistakes)
- [10. Quick command cheat sheet](#10-quick-command-cheat-sheet)
- [11. When to ask for help](#11-when-to-ask-for-help)
- [12. Acknowledgment](#12-acknowledgment)

---

## 1. Start here: the fastest troubleshooting checks

Before doing anything complicated, check these five things.

### Check 1: Are you in the right terminal?
In practice, the cleanest approach is to work from the **base terminal** and load the software you need there with `ml`. That avoids confusion about which terminal you are in.

For example:

```bash
ml fsl/6.0.7.16
# or, if instructed otherwise
ml fsl
```

Then you can run FSL commands from that same base terminal:
- `fsleyes`
- `bet`
- `Feat`
- `fslmaths`
- `fslstats`

### Check 2: Where are you right now?
Run:

```bash
pwd
```

This prints your current working directory.

### Check 3: Does the file or folder actually exist?
Run:

```bash
ls
ls path/to/folder
```

### Check 4: Are you using the exact path you think you are using?
Many errors come from small path mistakes: wrong dataset, wrong subject, wrong run, wrong output folder, or forgetting that `~` means your home directory.

### Check 5: Did the program finish, but the report failed?
This happens sometimes. If so, the actual output files may still exist even if an HTML page is blank or incomplete. In that case, inspect the output folder directly.

---

## 2. Linux navigation basics

For many people, the main issue is not fMRI analysis itself. The main issue is getting comfortable with where files live and how commands interpret paths.

### 2.1 Where am I?

Use:

```bash
pwd
```

Example output:

```bash
/home/jovyan
```

That means you are in your home directory.

### 2.2 What is in this folder?

Use:

```bash
ls
```

A more informative version is:

```bash
ls -lh
```

That shows files with sizes and permissions in a clearer format.

### 2.3 How do I move around?

Use `cd`.

```bash
cd ~
cd ~/ds003745
cd ~/Lab_2/OUTPUT
cd ..
```

Common patterns:
- `cd ~` goes to your home directory
- `cd ..` goes up one level
- `cd foldername` moves into a folder inside your current folder

### 2.4 Absolute vs relative paths

An **absolute path** starts from the top of the filesystem.

```bash
/home/jovyan/ds003745/sub-104/func/sub-104_task-trust_run-01_bold.nii.gz
```

A **relative path** starts from wherever you are right now.

```bash
sub-104/func/sub-104_task-trust_run-01_bold.nii.gz
```

If you are unsure, use the absolute path or use `~`.

```bash
~/ds003745/sub-104/func/sub-104_task-trust_run-01_bold.nii.gz
```

### 2.5 Create folders before writing output

Many programs expect the parent folder to exist already.

```bash
mkdir -p ~/Lab_2/OUTPUT
mkdir -p ~/Lab_3/OUTPUT
```

The `-p` flag prevents errors if the folder already exists.

### 2.6 Find a file when you are lost

If you know part of the filename, `find` is extremely helpful.

```bash
find ~ -name "sub-104.html"
find ~ -name "filtered_func_data.nii.gz"
find ~ -name "*.feat"
find ~ -name "*confounds*.tsv"
```

If you think the file is inside a specific folder:

```bash
find ~/Lab_2 -name "*.feat"
```

---

## 3. Base terminal and loading FSL with `ml`

Older instructions sometimes distinguish between a base terminal and an FSL terminal. That distinction can be useful conceptually, but for this course the simpler workflow is usually better: **start in the base terminal and load FSL there with `ml`**.

### Recommended workflow
Use the base terminal for general Linux work and for launching FSL after loading the module.

```bash
ml fsl/6.0.7.16
# or
ml fsl
```

Once FSL is loaded, commands such as these should work from the same base terminal:

```bash
fsleyes
bet
Feat
fslmaths
fslstats
```

Commands such as these should also work from the base terminal without any special workaround:

```bash
git
python
pip
datalad
```

### Common symptom
You type a command and get:

```bash
command not found
```

In this course, the first thing to check is usually whether the needed software has been loaded in the **base terminal**.

Try:

```bash
ml fsl/6.0.7.16
which bet
which fsleyes
```

If `which` returns a path, the command is available.

---

## 4. DataLad and downloaded files

Most students should be able to use `datalad` from the **base terminal** without any special workaround. In this course, that is the expected setup.

### Problem: the filename looks strange in FSLeyes
Sometimes DataLad-managed files are stored as symlinks into `.git/annex/objects/...`. That can make filenames look confusing in viewers, even when the file itself is fine.

If needed, you can inspect whether a file is a symlink:

```bash
ls -l ~/ds001734/derivatives/fmriprep/sub-001/anat/sub-001_T1w_preproc.nii.gz
```

If `datalad` itself does not work from the base terminal, do not spend a lot of time inventing workarounds. Contact the instructor so the issue can be replicated before it is treated as a broader course or Neurodesk problem.

---

## 5. I cannot find my output

This is one of the most common problems, and it is usually a **navigation problem**, not a processing problem.

### First, check what output path you told the program to use
For example, you might create:

```bash
mkdir -p ~/Lab_9/OUTPUT
```

But FEAT still needs a more specific output name such as:

```bash
~/Lab_9/OUTPUT/L1output
```

FEAT then adds an extension based on analysis level:
- lower level: `L1output.feat`
- higher level: `L2output.gfeat`

So the final folder is often **not** exactly the folder name you typed.

### Useful checks

```bash
ls ~/Lab_9/OUTPUT
find ~/Lab_9/OUTPUT -maxdepth 2 -type d
find ~/Lab_9/OUTPUT -name "*.feat"
find ~/Lab_9/OUTPUT -name "*.gfeat"
```

### FEAT outputs to know
Inside a `.feat` folder, common files include:

```bash
filtered_func_data.nii.gz
report.html
report_reg.html
stats/
```

Inside a `.gfeat` folder, you will usually see `cope*.feat` folders.

### A very common mistake
Students often make the parent folder but forget that FEAT creates a **new subfolder** with its own extension. If you are looking only for `~/Lab_9/OUTPUT`, you may miss `~/Lab_9/OUTPUT/L1output.feat`.

---

## 6. FEAT troubleshooting

### 6.1 FEAT output naming and folder structure

Give each FEAT run a clear output name.

Good examples:

```bash
sub-104_run-01_mcflirt
sub-104_run-01_betfunc
food_L1_cluster
food_L1_smooth10
```

This helps you avoid overwriting old runs and makes it much easier to know which folder corresponds to which analysis.

---

### 6.2 The Post-stats tab is blank

This issue came up in the troubleshooting forum. In at least one case, the **Stats** page appeared normally, but **Post-stats** was blank even though FEAT had actually finished.

### What to check
1. Open the **Stats** page. If the design matrix and contrasts look normal, the model itself may be fine.
2. Check whether FEAT still created the output folder.
3. Open the resulting images directly in `fsleyes` instead of relying on the HTML page.

### What this likely means
Sometimes the report-generation step breaks even though the main analysis finishes.

### What to do
Look inside the FEAT output folder:

```bash
ls ~/Lab_3/OUTPUT
find ~/Lab_3/OUTPUT -name "*.feat"
```

Then inspect files such as:

```bash
filtered_func_data.nii.gz
stats/zstat1.nii.gz
stats/thresh_zstat1.nii.gz
```

You can open them in FSLeyes:

```bash
fsleyes ~/Lab_3/OUTPUT/your_output_name.feat/stats/thresh_zstat1.nii.gz &
```

### Practical takeaway
A blank Post-stats page does **not automatically mean the analysis failed**. Check the output files before rerunning everything.

---

### 6.3 My structural image does not look skull-stripped in the report

This can happen for a few different reasons.

### First, confirm that BET itself worked
Open the BET output directly:

```bash
fsleyes ~/Lab_2/OUTPUT/sub-104_T1w_brain.nii.gz &
```

If the brain looks reasonably stripped there, BET probably worked.

### Next, confirm that FEAT is using the correct structural image
In the **Registration** tab, make sure the **Main structural** image is the skull-stripped file, for example:

```bash
~/Lab_2/OUTPUT/sub-104_T1w_brain.nii.gz
```

### Important detail for BBR users
If you are using BBR, FEAT expects the BET'd and non-BET'd images to be in the same folder. That is why the lab suggests copying the original T1 into the same output folder:

```bash
cp ~/ds003745/sub-104/anat/sub-104_T1w.nii.gz ~/Lab_2/OUTPUT/sub-104_T1w.nii.gz
```

### If the report still looks odd
Do not rely on a single screenshot. Check:
- whether the correct file was selected in FEAT
- whether the BET image itself looks reasonable in FSLeyes
- whether the registration alignment is acceptable at the brain edges and ventricles

In other words, distinguish between:
1. **BET failed**, and
2. **the report is confusing but the inputs are actually correct**.

---

### 6.4 My model setup looks wrong or FEAT will not proceed

If FEAT behaves strangely during first-level modeling, check these items.

### 3-column timing files
A surprising number of problems come from event files.

Each 3-column timing file should contain:
1. onset
2. duration
3. weight

Make sure:
- the file is tab- or space-delimited plain text
- there are three columns
- onsets make sense for the run
- you selected the correct file for the correct EV

You can inspect a file quickly with:

```bash
head ~/ds005085/sub-10015/func/_guess_allLeftButton.txt
cat ~/ds000157/sub-01/func/sub-01_food.txt | head
```

### Design matrix / contrasts
If the design matrix looks empty or obviously wrong, revisit:
- the number of EVs
- the timing files attached to each EV
- the contrasts

### Output name conflicts
If you rerun FEAT many times without changing the output name, old folders can create confusion. Use a new output name for each run.

---

## 7. fMRIPrep troubleshooting

### 7.1 FreeSurfer license problems

fMRIPrep expects a FreeSurfer license file even when you use `--fs-no-reconall`.

### What the file should look like
The license file should be a real FreeSurfer license with **multiple lines of text**. In practice, it should have **five lines**, not a single line of pasted text.

### Where it should live

```bash
~/.license
```

### Check it

```bash
ls -l ~/.license
cat ~/.license
```

If `cat ~/.license` shows only one line, the file may be corrupted or pasted incorrectly.

### Practical note
This seems to be rare, but if fMRIPrep refuses to start because of the license, this is one of the first things to check.

---

### 7.2 SUBJECTS_DIR problems

If fMRIPrep complains about `SUBJECTS_DIR`, create one and export it:

```bash
mkdir -p ~/Lab_2/freesurfer_subjects
export SUBJECTS_DIR=~/Lab_2/freesurfer_subjects
```

Then rerun fMRIPrep.

---

### 7.3 Memory / resource problems

If fMRIPrep crashes or runs out of memory, reduce resources.

Example:

```bash
NTHREADS=4 OMP_NTHREADS=1 MEM_MB=12000 bash fmriprep_lab2.sh 104
```

Or, if running directly, reduce the values in the command you are using.

---

### 7.4 I cannot find the report or output files

Common locations:

```bash
~/Lab_2/fmriprep_out/fmriprep/sub-104.html
~/Lab_2/fmriprep_out/fmriprep/sub-104/func/
```

Use:

```bash
find ~/Lab_2/fmriprep_out -name "sub-104.html"
find ~/Lab_2/fmriprep_out -name "*desc-preproc_bold.nii.gz"
find ~/Lab_2/fmriprep_out -name "*desc-confounds_timeseries.tsv"
```

---

### 7.5 HTML report does not open correctly

Some HTML reports, especially fMRIPrep reports, may not render correctly when opened directly through the Neurodesktop graphical interface.

### Better approach
Open them through **Jupyter Notebook/Lab** from the Neurodesk hub.

### General process
1. Leave Neurodesktop running.
2. Go back to the Neurodesk hub page in your browser.
3. Launch **Jupyter**.
4. Navigate to the relevant output folder.
5. Open the HTML file there.
6. If it opens as raw HTML text, open it in a new tab.

If something looks blank, your browser may be blocking pop-ups or embedded content.

---

## 8. fsleyes troubleshooting

### Problem: nothing opens
Use the **base terminal**, load FSL there if needed, and then launch FSLeyes:

```bash
ml fsl/6.0.7.16
fsleyes &
```

### Problem: the wrong file opens or filenames are confusing
Double-check the full path you passed in. This is especially important with DataLad-managed files.

### Problem: I want to compare raw and processed files
Open both at once:

```bash
fsleyes \
  ~/ds003745/sub-104/func/sub-104_task-trust_run-01_bold.nii.gz \
  ~/Lab_2/OUTPUT/sub-104_run-01_mcflirt.feat/filtered_func_data.nii.gz &
```

### Problem: I am not sure whether the output is sensible
Check visually:
- tissue boundaries
- ventricles
- brain edges
- whether distortions or motion seem reduced

Do not assume that a file is good just because it exists.

---

## 9. Common command-line mistakes

### Mistake 1: forgetting spaces
This fails:

```bash
cd~/Lab_2
```

This works:

```bash
cd ~/Lab_2
```

### Mistake 2: using the wrong capitalization
Linux is case-sensitive.

These are different:

```bash
Feat &
feat &
```

If the lab tells you to use `Feat &`, use that exact capitalization.

### Mistake 3: typing the path incorrectly
A single missing slash or wrong subject number is enough to break a command.

### Mistake 4: forgetting that the output folder is nested
FEAT often creates `something.feat` or `something.gfeat` **inside** the parent output folder.

### Mistake 5: assuming nonzero voxels equal brain volume
This issue came up in the forum. If you run:

```bash
fslstats ~/ds001734/derivatives/fmriprep/sub-001/anat/sub-001_T1w_preproc.nii.gz -V
```

and get an unrealistically large value, the likely problem is conceptual rather than syntactic. `-V` counts **nonzero voxels** in the image. For a preprocessed anatomical image, that may include lots of voxels outside the brain. A more realistic estimate usually requires an explicit brain mask or some thresholding approach.

So the problem is often not that the command is broken. The problem is that the image being measured is not a clean brain-only mask.

---

## 10. Quick command cheat sheet

### Navigation

```bash
pwd
ls
ls -lh
cd ~
cd ..
mkdir -p ~/Lab_2/OUTPUT
find ~ -name "*.feat"
```

### Check whether a command exists

```bash
which fsleyes
which bet
which fmriprep
```

### Load software

```bash
ml fsl
ml fmriprep/25.1.3
```

### View files

```bash
fsleyes some_file.nii.gz &
head some_text_file.txt
cat ~/.license
```

### Search for outputs

```bash
find ~/Lab_2 -name "filtered_func_data.nii.gz"
find ~/Lab_2 -name "sub-104.html"
find ~/Lab_3 -name "*.feat"
```

---

## 11. When to ask for help

Have a **low threshold** for asking questions. The preferred place to ask for help or report problems is the **Troubleshooting Discussion Board on Canvas**. That helps in two ways: other students can see the same issue and respond, and recurring problems stay visible in one place rather than getting repeated privately.

Before you post, it still helps to do a few quick checks:
- confirm that you are in the **base terminal**
- use `pwd` to check where you are
- use `ls` or `find` to confirm that the file or folder exists
- use `which` to confirm that the command is available
- check whether the output folder was actually created

When you ask for help, include:
1. the exact command you ran
2. the full error message
3. what you expected to happen
4. what you already checked

A screenshot can help, but a copy-pasted error message is often even better.

---

## 12. Acknowledgment

This page was generated with the help of **ChatGPT** and then revised across multiple iterations with instructor review and checking. The final version reflects course-specific corrections, clarifications, and decisions made by the instructor.

---

## Final reminder

Most troubleshooting in this course is really about three things:
- knowing where your files are
- working from the **base terminal** and loading software there with `ml`
- checking actual output files rather than assuming a blank report means total failure

When in doubt, slow down, check paths, and verify one step at a time.
