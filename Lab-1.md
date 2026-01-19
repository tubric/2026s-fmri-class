# Lab 1: Exploring Brain Anatomy (and what MRI data look like)

## Learning Objectives
This lab will help you get comfortable **loading, viewing, and describing MRI/fMRI data**. By the end, you should be able to:

- Load and view anatomical (3D) and functional (4D) MRI data in **fsleyes**
- Describe key differences between anatomical vs. functional images (resolution, contrast, noise)
- Estimate basic properties of the adult human brain (dimensions and approximate volume)
- Explain (at a basic level) how **gray matter** differs from **white matter**
- Identify several major anatomical structures using MNI space and an atlas

---

## Introduction
The human brain is incredibly complex. Although it weighs only about **3 pounds (≈1.3 kg)**, it contains ~100 billion neurons, plus several times as many supporting cells.

MRI cannot resolve individual neurons (they are on the order of micrometers), but it *can* tell us a great deal about brain anatomy and physiology at the scale of **millimeters to centimeters**. In this lab, you’ll learn what MRI data “look like,” how to navigate them, and how to start making basic measurements and interpretations from the images.

---

## Data Sets Used
![Figure](images/lab1/image1.png)

Most datasets in this course follow the **Brain Imaging Data Structure (BIDS)** standard:  
https://bids.neuroimaging.io/

BIDS makes files and folders easier to navigate. Each subject is in a folder like `sub-XXX`, and the main subfolders include:

- `anat/` for 3D anatomical scans (e.g., T1w, T2w)
- `func/` for 4D functional scans (BOLD data over time)

Each NIfTI image (`.nii` or `.nii.gz`) is typically paired with a JSON file containing scan metadata.

---

# 1) Viewing the brain in fsleyes

In this lab you will view two types of MRI data:

- **Anatomical images (3D):** high-resolution structure (e.g., T1w, T2w)
- **Functional images (4D):** lower resolution, measured repeatedly over time (BOLD contrast)

You will use **fsleyes** (part of FSL) to view data in 3D or 4D, and to overlay images.

---

## 1.1 Download the MRI data (Neurodesk base terminal)

In the **base terminal** in Neurodesk, download two OpenNeuro datasets with `datalad`.

```bash
datalad install https://github.com/OpenNeuroDatasets/ds001734.git
cd ds001734
datalad get sub-001
datalad get ~/ds001734/derivatives/fmriprep/sub-001/anat/sub-001_T1w_preproc.nii.gz

datalad install https://github.com/OpenNeuroDatasets/ds003745.git
cd ds003745
datalad get sub-104
datalad get sub-137
```

---

## 1.2 Load the MRI data in fsleyes (FSL terminal)

Run the commands below **in the FSL terminal**. Each `&` opens the viewer in the background so you can open multiple windows.

```bash
fsleyes ~/ds001734/derivatives/fmriprep/sub-001/anat/sub-001_T1w_preproc.nii.gz &

fsleyes ~/ds001734/sub-001/func/sub-001_task-MGT_run-01_bold.nii.gz &

fsleyes ~/ds003745/sub-104/anat/sub-104_T1w.nii.gz &

fsleyes ~/ds003745/sub-104/anat/sub-104_T2w.nii.gz &
# & opens windows in the background so you can keep using the terminal
```

Optional (also explore sub-137):

```bash
fsleyes ~/ds003745/sub-137/anat/sub-137_T1w.nii.gz &
fsleyes ~/ds003745/sub-137/anat/sub-137_T2w.nii.gz &
```

**Quick interpretation prompt:** sub-104 and sub-137 differ noticeably. One participant is significantly older than the other.  
**Before you look anything up:** What visual evidence would you use to justify your guess?

---

## 1.3 Compare what you see (short responses)

Display each dataset in its own window.

**Q1. T1 vs. T2 (sub-104):** What features look *the same* across T1 and T2?  
(Think: major structures, symmetry, overall anatomy.)

**Q2. T1 vs. T2 (sub-104):** What features look *different*, and why?  
(Think: contrast—what is bright vs. dark, and what tissue types those differences reveal.)

> **At this point, you should work more independently. TAs/instructor are available as needed.**

---

# 2) Navigating anatomy with a standard brain template

Now open a standardized (“normalized”) template brain in MNI space:

```bash
fsleyes /opt/fsl-6.0.7.16/data/standard/MNI152_T1_0.5mm.nii.gz &
```

![Figure](images/lab1/image2.png)

### Key ideas to understand here
- MRI volumes have 3 spatial dimensions: **X (left–right), Y (posterior–anterior), Z (inferior–superior)**
- Functional MRI adds a 4th dimension: **time**
- fsleyes shows the brain from three standard views:
  - **Sagittal** (side view)
  - **Coronal** (front view)
  - **Axial** (top view)

Use your mouse or the coordinate fields to move through the brain.

**Interpretation prompt:**  
When you click a location, fsleyes gives coordinates. In neuroimaging papers, coordinates are one of the main “languages” people use to communicate findings. This is why learning to navigate images *matters*.

---

# 3) Functional MRI is time-series data

Functional data are 4D: the scanner repeatedly samples the same brain volume over time.

Open the functional dataset window:

`sub-001_task-MGT_run-01_bold.nii.gz`

Then:  
**Click any voxel inside the brain → View → Time series**

A plot will appear showing signal intensity over time for that voxel.

![Figure](images/lab1/image3.png)

**Q3.** Click 3–5 very different locations (gray matter, white matter, near edges of brain, etc.).  
What differences do you notice in the time series patterns?  
(Think: stability, noise, slow drifts, spikes, plausible artifacts.)

---

# 4) Measuring the brain (roughly)

MRI can be used to quantify brain structure (e.g., volume differences across individuals).

In your **FSL terminal**, estimate the volume of the anatomical scan using `fslstats`:

```bash
fslstats ~/ds001734/derivatives/fmriprep/sub-001/anat/sub-001_T1w_preproc.nii.gz -V
```

This returns two values:
1) number of voxels in the image mask  
2) total volume (in mm³)

**Q4.** Report the approximate brain volume (mm³) and convert it to cm³.  
(1 cm³ = 1000 mm³)

**Deep thinking prompt:**  
Is your estimated value closer to the volume of a soda can, a grapefruit, or a basketball?  
What does that tell you about scale (and why fMRI voxels feel “big” compared to neurons)?

---

# 5) Finding the gray/white boundary (intensity + uncertainty)

A major anatomical distinction:
- **Gray matter**: cell bodies, cortical ribbon (outer layer)
- **White matter**: axons connecting regions

On T1-weighted images, white matter is usually brighter than gray matter.

There are two ways to estimate the gray/white boundary:

### Option A (quick + rough)
Click a few locations in obvious gray matter and obvious white matter and compare intensities.  
Try to find a “transition zone” where values change from gray → white.

### Option B (histogram-based)
Use: **View → Image histogram**  
Click the wrench to adjust settings (suggested settings shown below).

<img width="1655" height="968" alt="image" src="https://github.com/user-attachments/assets/8a0cbe41-e60d-42cb-9a24-2e69a4eb11c3" />

You should see:
- a giant peak near 0 (air/background)
- two smaller peaks (gray vs white)

You can zoom the histogram range to focus on white matter  
(e.g., ~370–430 in this particular image).

<img width="1010" height="971" alt="image" src="https://github.com/user-attachments/assets/f2fb9436-c0ba-488a-a04a-3a79ad739788" />

**Q5 (challenge—conceptual + quantitative):**  
Pick a reasonable threshold that separates “mostly gray” from “mostly white.” Then answer:

1) What threshold did you choose, and why?  
2) What are *two* reasons your threshold will be imperfect?  
   (Hint: partial volume effects, scanner differences, intensity inhomogeneity, tissue mixtures.)

*Optional extension:* Use `fslstats` to estimate how many voxels fall above your “white matter” threshold.

---

# 6) Identifying anatomical locations with an atlas

Now return to the template brain:  
`MNI152_T1_0.5mm.nii.gz`

To make structure identification easier, turn on an atlas:

**Settings → Ortho View 1 → check “Atlases”**

<img width="910" height="707" alt="image" src="https://github.com/user-attachments/assets/602c9392-02f2-4641-a716-fc2088287576" />

Then:

**Atlases → Atlas information… → select atlas (e.g., Harvard-Oxford Cortical) → Show/Hide**

<img width="913" height="690" alt="image" src="https://github.com/user-attachments/assets/3fdca10e-e26b-4dba-bded-004ff525314b" />

When you click a voxel, the atlas provides the most likely label at that location.

**Q6.** Using the atlas + coordinates, find approximate locations for the regions below:

### Cortex
- Inferior Frontal Gyrus: X ____ Y ____ Z ____
- Middle Frontal Gyrus: X ____ Y ____ Z ____
- Superior Frontal Gyrus: X ____ Y ____ Z ____
- Inferior Temporal Gyrus: X ____ Y ____ Z ____
- Middle Temporal Gyrus: X ____ Y ____ Z ____
- Superior Temporal Gyrus: X ____ Y ____ Z ____
- Occipital Pole: X ____ Y ____ Z ____
- Temporal Pole: X ____ Y ____ Z ____
- Frontal Pole: X ____ Y ____ Z ____
- Postcentral Gyrus: X ____ Y ____ Z ____
- Lingual Gyrus: X ____ Y ____ Z ____
- Orbital Frontal Gyrus: X ____ Y ____ Z ____

### Subcortex
- Left Thalamus: X ____ Y ____ Z ____
- Right Hippocampus: X ____ Y ____ Z ____
- Right Accumbens: X ____ Y ____ Z ____
- Left Pallidum: X ____ Y ____ Z ____

**Deep thinking prompt:**  
Pick one cortical region and one subcortical region. For each, write one sentence explaining a research question where that region might matter *and* what kind of task or contrast could plausibly engage it.

---

# Summary Questions

**Q7.** Visually compare functional vs anatomical images.  
What do you notice about resolution, smoothness, contrast, and distortion?

**Q8.** Set Z=21 for functional image `sub-001_task-MGT_run-01_bold.nii.gz`,  
set Z=55 for anatomical image `sub-001_T1w.nii.gz`, and compare side-by-side.  
What differences stand out, and what do those differences imply for interpretation?

**Q9.** How many volumes are in the anatomical scan? How many volumes are in the functional image?  
What does “volume” represent in each case?

![Figure](images/lab1/image7.png)

X =
Y =
Z =

**Why might researchers prefer one view over another when describing results?**

---

[^1]: Other free programs exist (MRIcroN / MRIcroGL), and you may see them used in the literature. In this course, we’ll focus on FSL tools.
