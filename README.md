# fMRIPrep Workshop UWM 2023 

## Overview

The primary goal of this wokshop is to enable Mortimer users at UWM to go from raw DICOM neuroimaging data to preprocessed output from fMRIPrep. This process has been broken down into three sections based on the data requirements at each stage.

The first step will is to [convert raw DICOM files into a BIDS compliant data structure](./1_DICOMToBIDSConversion/). This takes the longest, but users who already have a BIDS complaint dataset can skip this step.

The second step is [defacing the structural scans](./2_DefacingWithMiDeFace2/) to prevent identification of research subjects This will only be required for data which you might want to share. If you already have a BIDS compliant dataset to use, you can skip this step.

The final step is [running fMRIPrep](./3_RunningfMRIPrep/). If you already have a BIDS dataset on the cluster, this is all you will need to get started.

There is also a brief section on [some commands which you might find useful](./0_CommonlyUsedCommands/) in the Mortimer environment. Keeping that page open may facilitate more understanding of what some of the steps along the way are doing.

You will find a lot of links to other documentation as we go through each of the steps. Please take the time to expolore those links. This tutorial is somewhat specific to the Mortimer system. Those links are to the formal (although more generic) explanations and instructions for the systems and concepts we will be using. If you are attending the workshop in person or virtually, I will give a brief tour of relevant links as we go.

## Setting up directories
If you are attending the workshop and plan on following along, I recommend setting up the following directories prior to getting started. You are welcome to use your own file structure/naming convention, but you will need to adapt the code to your file structure if you do so. There will be reminders for all of these directories in the sections where they are relevant.

```bash
# Directory for Conda environments
mkdir ~/Data/${USER}/conda_envs
# Directory for workshop content
mkdir ~/Data/${USER}/fmriprep_workshop
# Set up a directory to store the error and output files from Slurm Jobs
mkdir ~/Data/${USER}/fmriprep_workshop/outputAndErrors
# Directory for fmriprep 'work'
mkdir ~/Data/${USER}/work
# Create a symbolic link to the work directory in your home directory
ln -s "$(realpath ~/Data)"/${USER}/work/ ~/work

```

## Table of contents
- [Commonly Used Commands Bash Commands](./0_CommonlyUsedCommands/)
- [DICOM 2 BIDS Conversion](./1_DICOMToBIDSConversion/)
  - [Setting up Conda/Python](./1_DICOMToBIDSConversion/1-0_CondaPythonSetup/)
  - [Using dcm2bids](./1_DICOMToBIDSConversion/1-1_UsingDcm2bids/)
- [Defacing with MiDeFace2](./2_DefacingWithMiDeFace2/)
- [Running fMRIPrep](./3_RunningfMRIPrep/)

## Acknowledgements
