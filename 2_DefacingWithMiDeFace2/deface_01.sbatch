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