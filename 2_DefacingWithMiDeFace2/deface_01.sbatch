#!/bin/bash 
#SBATCH --job-name=deface_01
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=0-1
#SBATCH --mem=3G
#SBATCH --output=/home/kbaacke/Data/kbaacke/fmriprep_workshop/outputAndErrors/deface_01-%A_%a.out 
#SBATCH --error=/home/kbaacke/Data/kbaacke/fmriprep_workshop/outputAndErrors/deface_01-%A_%a.err


FREESURFER_HOME=/sharedapps/LS/psych_imaging/freesurfer/7.2.0/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

SUBJECT_LIST=($(cut -f1 -d$'\t' ~/Data/${USER}/some_bids_dataset/participants.tsv))
SUBJECT=${SUBJECT_LIST[${SLURM_ARRAY_TASK_ID}]}
SUBJECT_DIR=~/Data/${USER}/some_bids_dataset/sub-${SUBJECT}/

for SESSION in $(ls $SUBJECT_DIR)
do
  ANAT_DIR=${SUBJECT_DIR}/${SESSION}/anat
  for TARGET_FILE in  $(ls ${ANAT_DIR}/*.nii.gz) 
  do
    mideface --i $TARGET_FILE --o $TARGET_FILE --odir qa
    echo "Defaced ${TARGET_FILE}"
  done
done

