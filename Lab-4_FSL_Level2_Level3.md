# Lab 4: Higher-level statistics in FSL (Level 2 and Level 3)

## Learning objectives
In this lab, you will move beyond first-level modeling and run **higher-level FEAT analyses** in FSL.

By the end, you should be able to:

- Run **Level 2 (L2)** analyses that combine multiple runs within a single participant
- Run **Level 3 (L3)** analyses that combine data across participants
- Understand what higher-level FEAT inputs and outputs represent
- Interpret the main outputs from higher-level analyses

For this lab, you will use the `srndna-trustgame` dataset. The **Level 1 FEAT analyses have already been completed** for six subjects, and each subject has **five runs**.

In this context:
- **Level 2** combines runs within a participant
- **Level 3** combines participants at the group level

---

## Before you begin

### Folder structure (outputs)
Keep your work in a dedicated lab folder:

```bash
mkdir -p ~/Lab_4/OUTPUT
```

### Terminals (Neurodesk)
For this lab, it is usually simplest to work from the **base terminal** and load FSL there. That approach avoids confusion about which terminal you are using.

```bash
ml fsl/6.0.7.16
```

If your system uses a slightly different FSL module name, use the available version on your machine.

---

## 1) Set up your working directory

### 1.1 Create your lab folder
If you have not already done so, create a folder for this lab:

```bash
mkdir ~/Lab_4
```

### 1.2 Download the data
This lab uses a preprocessed dataset (~7 GB) hosted on OneDrive.

⚠️ Due to OneDrive limitations, **you must download this file manually through your Neurodesk browser**.

[Download Lab 4 Data from OneDrive](https://tuprd-my.sharepoint.com/:u:/g/personal/tug87422_temple_edu/IQArYdWo3ri2SLhqi3lyrb-yARG3SFPKehZf-op4vDnDkDA?e=nhzujm)

This is a large compressed file, so it may take a while to download. Please do this ahead of time.

Once the file has downloaded, move it into your lab folder and unzip it:

```bash
mv ~/Downloads/__forNSCI8010_L2L3stats+PPI.zip ~/Lab_4/
cd ~/Lab_4
unzip __forNSCI8010_L2L3stats+PPI.zip
```

This will extract the **Level 1 FEAT directories** for runs 1-5 for each subject.

---

## 2) Run Level 2 (within-subject) analyses

You will run the same **Level 2 fixed-effects model once for each subject**. Each Level 2 analysis combines that subject’s five Level 1 runs.

### 2.1 Launch FEAT
From the terminal where FSL is loaded, enter:

```bash
Feat &
```

In the FEAT window:
- change **First-level analysis** to **Higher-level analysis**
- change **Full analysis** to **Statistics only**

![](images/lab5_54.png)

### 2.2 Configure the Data tab
For your first subject, set the following:

- **Output directory:** choose a clear base output name, such as `~/Lab_4/OUTPUT/sub-104_L2_act_sm-6`
  - FEAT will automatically add the higher-level extension, so the final output will end in `.gfeat`
- **Number of inputs:** **5** (one for each run)
- Click **Select FEAT directories**
  - For each row, select the appropriate run-level `.feat` directory
  - Example:
    - `~/Lab_4/__forNSCI8010_L2L3stats+PPI/sub-104/L1_task-trust_model-01_type-act_run-01_sm-6.feat`
  - Repeat this for all five runs for that subject
  - A practical shortcut is to paste the first path and then edit only the run number for runs 2-5

![Selecting input FEAT directories L3](images/lab5_image_04.png)

After you finish one subject, repeat the same Level 2 setup for the remaining subjects. By the end of this step, you should have **one `.gfeat` directory per subject**.

### 2.3 Configure the Stats tab
- Set **Mixed effects** to: `Fixed Effects`
- Click **Full model setup**
  - **EV1 name:** `Run_Average`
  - For each input, set the EV1 value to `1`
   ![](images/lab5_72.png)
  - Set **2 contrasts**:
    - one positive contrast: `+1`
    - one negative contrast: `-1`

   ![](images/lab5_76.png)

### 2.4 Post-stats tab
- Leave the default settings in place
- Click **GO** to run the analysis

---

## 3) Run the Level 3 (group-level) analysis

After you have completed the Level 2 analysis for all six subjects, you are ready to run the group model.

### 3.1 Launch FEAT again

```bash
Feat &
```

In the FEAT window:
- select **Higher-level analysis**
- choose **Statistics only**

### 3.2 Configure the Data tab
![](images/lab5_96.png)

Set the following:

- **Output directory:** choose a clear base output name, such as `~/Lab_4/OUTPUT/L3_cope11`
  - FEAT will add the appropriate higher-level output extension automatically
- **Input type:** `3D cope images from FEAT directories`
- **Number of inputs:** **6** (one per subject)
- Click **Select FEAT directories**, then add the `cope11.feat` directory for each subject from the Level 2 outputs

For example, if you used the suggested naming above, one input would look like:
- `~/Lab_4/OUTPUT/sub-104_L2_act_sm-6.gfeat/cope11.feat`

**Important:** In the FEAT GUI, you should select the `cope11.feat` directories. Internally, FEAT will use the relevant `stats/cope1.nii.gz` image from each of those directories.

**Pro-tip:** From the terminal, you can quickly list the Level 2 `cope11.feat` directories:

```bash
ls -1d ~/Lab_4/OUTPUT/sub-1*_L2*.gfeat/cope11.feat
```

Then copy the output, and in the FEAT selection window, click **Paste** near the bottom.
![](images/lab5_109.png)

Use `Ctrl+V` to paste, then press **OK**.

![](images/lab5_113.png)

### 3.3 Configure the Stats tab
- Set **Mixed effects** to: `FLAME 1` (given the small sample, try this with fixed effects as well)
- Click **Full model setup**
  - **EV1 name:** `Group_Average`
  - Set all EV1 values to `1`
- Under **Contrasts & F-tests**, set:
  - **Number of contrasts:** `2`
  - **Contrast 1:** Name = `positive`, value = `+1`
  - **Contrast 2:** Name = `negative`, value = `-1`

### 3.4 Post-stats tab
- Leave the default settings in place
- Click **GO** to run the analysis

---

## 4) Review your higher-level output

After the Level 3 analysis finishes, inspect the FEAT output and make sure the analysis completed as expected.

At minimum, look at:
- the **design matrix**
- the **thresholded z-stat maps**
- the main higher-level output directories and filenames

If you open the FEAT HTML report and the browser gives you trouble with HTML files, use the workaround described in the course troubleshooting materials.

---

## Lab 4 questions
Answer the following questions in complete sentences.

**Q1.** In a Level 2 analysis, why is **Fixed Effects** used instead of **FLAME 1** when combining runs within a single subject? What assumptions does that choice make about the data?

**Q2.** In the Level 3 analysis, what does the `cope1.nii.gz` file represent within each selected `cope11.feat` directory, and why is that image used as input to the group model?

**Q3.** After running your Level 3 analysis, how did you determine whether the group-level effect was significant? What brain regions, if any, showed activation for the contrast you examined?

**Q4.** Why is standard space (for example, `MNI152_T1_2mm_brain`) important for Level 3 analyses? What problem would arise if that step were skipped?

**Q5.** What does the design matrix represent in the Level 3 model? How did you specify it, and what does each row and column correspond to in this analysis?
