#!/bin/bash
#SBATCH --job-name=dcm2bids_helper_01
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=3G
#SBATCH --array=0-1
#SBATCH --output=~/Data/${USER}/fmriprep_workshop/outputAndErrors/dcm2bids_helper_01-%A_%a.out 
#SBATCH --error=~/Data/${USER}/fmriprep_workshop/outputAndErrors/dcm2bids_helper_01-%A_%a.err

. /sharedapps/LS/conda/miniconda/etc/profile.d/conda.sh
conda activate
conda activate ~/Data/${USER}/conda_envs/dcm2bids-env

SUBJECT_LIST=($(ls /sharedapps/LS/psych_imaging/fmriprep_workshop/dcm_qa_nih-master/In/))
SUBJECT=${SUBJECT_LIST[${SLURM_ARRAY_TASK_ID}]}
OUTPUT_DIR=~/Data/${USER}/fmriprep_workshop/RawNifti/
INPUT_DIR=/sharedapps/LS/psych_imaging/fmriprep_workshop/dcm_qa_nih-master/In/$SUBJECT

for SCAN_DIR in $(ls $SUBJECT_DIR)
do
  echo $SUBJECT $SCAN_DIR
  dcm2bids_helper -d $SUBJECT_DIR/$SCAN_DIR -o $OUTPUT_DIR/$SCAN_DIR --force
done