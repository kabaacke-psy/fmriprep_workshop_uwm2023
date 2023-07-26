## Defacing with MiDeFace2
With modern preprocessing techniques, it is possible to reconstruct a subject's face from their structural MRI scan with only one line of code. This means that all raw structural neuroimaging data inherently contain PII. In order to ensure confidentiality, it is necessary to obscure the faces and ears of structural scans before they are ready to share. There have been many ways to do this (e.g. PyDeface in Python and mri_deface from Free Surfer), but most methods either require some tuning to prevent data loss or don't remove enough to prevent facial identification from being possible with what remains. 

However, the most recent version of Free Surfer includes a new, minimally invasive tool for defacing images, [MiDeFace2](https://surfer.nmr.mgh.harvard.edu/fswiki/MiDeFace2) which seems to work very well. We will go through an example of running this process on one of the structural scans in the sample dataset used in the [dicom2bids tutorial](). 

### Set up Free Surfer
Before we can run MiDeFace2, we need to make sure the correct version of Free Surfer is active. The following lines will need to be added to our batch script:

```bash
FREESURFER_HOME=/sharedapps/LS/psych_imaging/freesurfer/7.2.0/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
```

### Run MiDeFace2
The full script to run this on all of the anatomical images in the dataset, parallelized on the level of the subject, is show below:

```bash
#!/bin/bash
#SBATCH --job-name=deface_01
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=0-1
#SBATCH --mem=3G
#SBATCH --output=~/Data/${USER}/fmriprep_workshop/outputAndErrors/deface_01-%A_%a.out 
#SBATCH --error=~/Data/${USER}/fmriprep_workshop/outputAndErrors/deface_01-%A_%a.err


FREESURFER_HOME=/sharedapps/LS/psych_imaging/freesurfer/7.2.0/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

SUBJECT_LIST=($(ls /sharedapps/LS/psych_imaging/fmriprep_workshop/dcm_qa_nih-master/In/))
SUBJECT=${SUBJECT_LIST[${SLURM_ARRAY_TASK_ID}]}
SUBJECT_DIR=~/Data/${USER}/fmriprep_workshop/bids_example_01/sub-${SUBJECT}/

mideface2 --i volume.mgz --o volume.defaced.mgz --odir qa
```
