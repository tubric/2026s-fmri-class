# Lab 1 Glossary: Linux + Neuroimaging Tools

This handout defines unfamiliar terms from **Lab 1** and gives quick background on the tools used for downloading, viewing, and inspecting MRI/fMRI data.

---

## 1) Linux / terminal basics

### Terminal / shell
A **terminal** is a text-based interface where you type commands. A **shell** (often `bash`) is the program that reads your commands and runs them.

### Command + arguments + options (flags)
Most command lines look like this:

```bash
command  input_or_path  option1  option2
```

Example:

```bash
fslstats sub-001_T1w_preproc.nii.gz -V
```

- `fslstats` = the command  
- `sub-001_T1w_preproc.nii.gz` = an input file (argument)  
- `-V` = an option (flag) that changes what the command outputs

### Working directory
Your **working directory** is “where you are” in the filesystem. Relative paths are interpreted from here.

Common commands:
```bash
pwd      # print working directory
ls       # list files
cd       # change directory
```

### Paths (absolute vs relative)
A **path** tells Linux where a file is.

- **Absolute path**: starts from the root `/`
  - Example: `/opt/fsl-6.0.7.16/data/standard/MNI152_T1_0.5mm.nii.gz`
- **Relative path**: starts from the current folder

### Home directory and `~`
`~` is shorthand for your home directory.

```bash
cd ~
```

### Running a command in the background (`&`)
Adding `&` runs a command in the background so your terminal stays usable:

```bash
fsleyes file.nii.gz &
```

### Getting help
Many tools print usage instructions if you run them with no arguments:

```bash
fslstats
```

---

## 2) Data and data-sharing concepts

### BIDS (Brain Imaging Data Structure)
**BIDS** is a community standard for organizing neuroimaging datasets using predictable folder names, file names, and metadata “sidecar” files.

Common patterns:
- `sub-XXX/` = participant folder  
- `anat/` = anatomical scans (3D)  
- `func/` = functional scans (4D time series)

Why it matters: BIDS makes datasets easier to share, reuse, and automate.

### OpenNeuro
**OpenNeuro** is a free platform for sharing and downloading BIDS-compliant neuroimaging datasets (MRI, EEG, MEG, etc.).

### DataLad
**DataLad** is a data management tool built on Git and git-annex. It can version-control dataset structure and download large files only when you need them.

Key commands:
```bash
datalad install <dataset-url>   # downloads the dataset "skeleton"/structure
datalad get <file-or-folder>    # downloads the actual file contents
```

Why this is useful: you can grab just one subject or one folder instead of the entire dataset.

---

## 3) Neurodesk and the main software tools

### Neurodesk / Neurodesktop
**Neurodesk** is a container-based environment for neuroimaging that bundles many tools in reproducible versions.  
**Neurodesktop** is the desktop-style interface many people use to run those tools.

Why it matters:
- avoids painful installs
- reduces “works on my computer” problems
- makes workflows more reproducible

### FSL (FMRIB Software Library)
**FSL** is a widely used suite of tools for MRI and fMRI analysis (registration, segmentation, modeling, statistics, and utilities).

### FSLeyes
**FSLeyes** is FSL’s viewer for 3D and 4D neuroimaging data. It supports overlays, time series viewing, and atlas labeling.

Common use cases in Lab 1:
- open anatomical (T1/T2) and functional (BOLD) data
- click voxels and inspect values over time
- view histograms of image intensity
- use atlases to label brain regions

### `fslstats`
`fslstats` computes summary statistics from image files.

The option used in Lab 1:
```bash
fslstats <image> -V
```

This returns:
1) number of **non-zero voxels**
2) total **non-zero volume** in **mm³**

A common extension is to apply a mask with `-k <mask>` to compute statistics only within a region.

### Module loading (`ml fsl` / `module load fsl`)
On clusters (and some shared systems), software is activated using environment modules:

```bash
ml fsl
# or
module load fsl
```

This sets up environment variables and paths so FSL commands work in your current terminal session.

---

## 4) File types you’ll see constantly

### NIfTI (`.nii` / `.nii.gz`)
**NIfTI** is the standard file format for volumetric neuroimaging data.

- `.nii` = uncompressed  
- `.nii.gz` = compressed (smaller on disk, very common)

NIfTI files often store:
- **3D** anatomical images (one volume)
- **4D** functional images (many volumes over time)

### JSON sidecars (`.json`)
BIDS datasets often include a `.json` file alongside imaging data.  
These contain acquisition metadata (scanner parameters, timing, etc.).

### Derivatives
A **derivative** is a processed output created from raw data (e.g., a preprocessed T1 image).  
Preprocessing pipelines store derivatives in `derivatives/`.

### fMRIPrep
**fMRIPrep** is a widely used preprocessing pipeline that takes BIDS datasets and outputs standardized preprocessed results (as BIDS-style derivatives).

---

## 5) Core imaging concepts in Lab 1

### Voxel
A **voxel** is a 3D pixel: a small box-shaped element of the brain image.

### 3D vs 4D data
- **Anatomical (3D)**: one brain volume, high spatial detail (T1w/T2w)
- **Functional (4D)**: many volumes over time, lower spatial resolution (BOLD fMRI)

### “Volume” (two meanings)
This word can mean two different things:

1) a **3D snapshot** (one image volume in a time series)  
2) a **physical amount of space** (e.g., brain volume in mm³)

### MNI space / template brain
**MNI space** is a standard coordinate system used to compare brains across people.  
A common reference image is the MNI152 template distributed with FSL.

### Coordinates: X, Y, Z
MRI volumes have three spatial axes:
- **X**: left–right  
- **Y**: posterior–anterior  
- **Z**: inferior–superior  

It’s also helpful to distinguish:
- **voxel indices** (grid positions)
- **real-world coordinates** (millimeters; often in template space)

### Atlas
An **atlas** is a labeled map of brain regions (often in a standard space).  
Many atlases are **probabilistic**, meaning they represent uncertainty in boundaries.

### Histogram (image intensity distribution)
A histogram shows how many voxels have each intensity value.  
It can help you understand tissue contrast and intensity ranges.

### Why intensity thresholding is imperfect
Two common reasons:
- **Partial volume effects**: one voxel can contain mixed tissue types  
- **Intensity inhomogeneity (bias field)**: the same tissue can vary in brightness across the image

---

## 6) Mini command translation (what Lab 1 is doing)

### Downloading data with DataLad
```bash
datalad install https://github.com/OpenNeuroDatasets/ds001734.git
cd ds001734
datalad get sub-001
```

Meaning: download the dataset structure, move into it, then fetch only subject 001.

### Opening images in FSLeyes
```bash
fsleyes sub-001_T1w_preproc.nii.gz &
```

Meaning: open the image in the viewer and keep the terminal free for other commands.

### Estimating volume (non-zero voxels)
```bash
fslstats sub-001_T1w_preproc.nii.gz -V
```

Meaning: count non-zero voxels and compute their total physical volume (mm³).

---
