# fMRIPrep Workshop UWM 2023
Description here

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

