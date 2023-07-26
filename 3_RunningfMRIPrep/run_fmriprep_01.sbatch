#!/bin/bash
#SBATCH --job-name=run_fmriprep_01
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --array=0-9
#SBATCH --mem=16G
#SBATCH --output=/home/kbaacke/Data/kbaacke/fmriprep_workshop/outputAndErrors/run_fmriprep_01_%A_%a.out 
#SBATCH --error=/home/kbaacke/Data/kbaacke/fmriprep_workshop/outputAndErrors/run_fmriprep_01_%A_%a.err

SUBJECT_LIST=('sub-MSC01' 'sub-MSC02' 'sub-MSC03' 'sub-MSC04' 'sub-MSC05' 'sub-MSC06' 'sub-MSC07' 'sub-MSC08' 'sub-MSC09' 'sub-MSC10')
SUBJECT=${SUBJECT_LIST[${SLURM_ARRAY_TASK_ID}]}

BIDS_DIR=/mnt/fmriprep_workshop_shared/ds000224-download
PROCESSED_DIR=/mnt/fmriprep_workshop/ds000224-download/derivatives/fmriprep_run_01

echo "Apptainer started @ $(date +%x_%H:%M:%S:%N)"

apptainer run --mount type=bind,src=$(realpath ~/Data)/${USER}/fmriprep_workshop,dst=/mnt/fmriprep_workshop --mount type=bind,src=$(realpath /sharedapps/LS/psych_imaging/fmriprep_workshop,dst=/mnt/fmriprep_workshop_shared /sharedapps/LS/psych_imaging/containers/fmriprep-23.1.3.sif $BIDS_DIR $PROCESSED_DIR participant --fs-license-file /mnt/fmriprep_workshop/freesurfer_license.txt --participant_label $SUBJECT --task-id "rest" --ignore slicetiming --output-spaces MNI152NLin2009cAsym --bold2t1w-dof 9 --return-all-components --skull-strip-template OASIS30ANTs --write-graph --stop-on-first-crash --fs-no-reconall --n_cpus 2

echo "Apptainer closed @ $(date +%x_%H:%M:%S:%N)"