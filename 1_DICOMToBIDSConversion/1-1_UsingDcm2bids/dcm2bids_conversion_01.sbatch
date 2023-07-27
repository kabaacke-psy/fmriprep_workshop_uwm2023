#!/bin/bash
#SBATCH --job-name=dcm2bids_conversion_01
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=0-1
#SBATCH --mem=3G
#SBATCH --output=/home/kbaacke/Data/kbaacke/fmriprep_workshop/outputAndErrors/dcm2bids_conversion_01-%A_%a.out 
#SBATCH --error=/home/kbaacke/Data/kbaacke/fmriprep_workshop/outputAndErrors/dcm2bids_conversion_01-%A_%a.err

. /sharedapps/LS/conda/miniconda/etc/profile.d/conda.sh
conda activate
conda activate ~/Data/${USER}/conda_envs/dcm2bids-env

SUBJECT_LIST=($(ls /sharedapps/LS/psych_imaging/fmriprep_workshop/dcm_qa_nih-master/In/))
SUBJECT=${SUBJECT_LIST[${SLURM_ARRAY_TASK_ID}]}
OUTPUT_DIR=~/Data/${USER}/fmriprep_workshop/bids_example_01/
SUBJECT_JSON=~/Data/${USER}/fmriprep_workshop/RawNifti/${SUBJECT}/${SUBJECT}_dcm2bids-config.json
SUBJECT_DIR=/sharedapps/LS/psych_imaging/fmriprep_workshop/dcm_qa_nih-master/In/$SUBJECT

dcm2bids -d $SUBJECT_DIR -p $SUBJECT -c $SUBJECT_JSON -s 01 -o $OUTPUT_DIR
echo "${SUBJECT} conversion complete."

