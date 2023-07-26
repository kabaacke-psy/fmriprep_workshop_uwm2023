# Running fMRIPrep
[fMRIPrep](https://fmriprep.org/en/stable/) extremely well documented, and I encourage you to reference the documentation (*specific to the version you are using*) when deciding which optional flags to use when running fMRIPrep. This tutorial follows the documentation provided by the creators of fMRIPrep for [Executing with Singularity](https://www.nipreps.org/apps/singularity/) in the context of the Mortimer System. If you would like to learn more about containers and their accompanying hosting softwares like singularity, please see [INSERT HELPFUL EXPLANATORY LINK HERE](). 

**Do not skip the following step if running fMRIPrep on Mortimer!**

The fMRIPrep pipeline saves files as it completes each step to enable the process to resume rather than restart is interrupted before completion. By default, these iterative files are saved in `~/work/`. If this directory does not exist, fMRIPrep will create it. If this runs without intervention, you will end up saving large amounts of data to the login node. This is bad and will create problems for everyone. To avoid this
1. create a `~/Data/${USER}/work/` directory
2. create a symbolic link to the real path of your data directory. This can be accomplished with the following commands:

```bash
# Directory for fmriprep 'work'
mkdir ~/Data/${USER}/work
# Create a symbolic link to the work directory in your home directory
ln -s "$(realpath ~/Data)"/${USER}/work/ ~/work
```

## Downloading and Building the fMRIPrep image
Once your work directory is set up, you can begin the process of downloading and building the container image of the version of fMRIPrep that you want to use. While we will be using [Apptainer](https://apptainer.org/) to run our containers, we will be downloading the required build files from [DockerHub](https://hub.docker.com/). Singularity has been renamed to Apptainer, but there are still actively maintained forks of Singularity. For our purposes, it is OK to use the terms interchangably. Docker is another container hosting software altogether, but it is less frequently used in cluster environments. Thankfully, Singularity can build images based on Docker container definition files. 

```bash
apptainer build ~/Data/${USER}/fmriprep_workshop/fmriprep-23.1.3.sif docker://nipreps/fmriprep:23.1.3

apptainer build /sharedapps/LS/psych_imaging/fmriprep_workshop/fmriprep-23.1.3.sif docker://nipreps/fmriprep:23.1.3
```

## Chosing which options to use
The typical use of fMRIPrep is to run the `run.sh` script which is aliased by default in the container image. Please see the documentation for your version of fMRIPrep for which flags to use in your context. 

Outside of the fMRIPrep options, you may also want to specify some container options. In the example below, one of the example datasets from the `/sharedapps/LS/psych_imaging/fmriprep_workshop` directory is mounted to the image.

```bash
apptainer run \  # Run container instance
    --mount type=bind,src=$(realpath ~/Data)/${USER}/fmriprep_workshop,dst=/mnt/fmriprep_workshop \  # Mont directory containing bids data
    /sharedapps/LS/psych_imaging/containers/fmriprep-23.1.3.simg \ # # Target the container image to run
    $BIDS_DIR \  # Location of the mounted bids directory
    $PROCESSED_DIR \  # Locaiton for the output Data
    participant \  # Level on which to run fmriprep
    --fs-license-file /mnt/fmriprep_workshop/freesurfer_license.txt \  # Path to freesurfer license file
    --participant_label $SUBJECT \  # Subject ID e.g. "sub-0001"
    --task-id $TASK \ Specify to only run on one task
    --ignore slicetiming \  # Don't correct for slice timing 
    --output-spaces MNI152NLin2009cAsym \  # Standard spaces to include
    --bold2t1w-dof 9 \  # Degrees of freedom when registering BOLD to T1w images.
    --return-all-components \  # Include all components estimated in CompCor decomposition in the confounds file instead of only the components sufficient to explain 50 percent of BOLD variance in each CompCor mask
    --skull-strip-template OASIS30ANTs \  # select a template for skull-stripping with antsBrainExtraction
    --write-graph \  # Write workflow graph.
    --stop-on-first-crash \  # Force stopping on first crash, even if a work directory was specified.
    --fs-no-reconall \  # disable FreeSurfer surface preprocessing. --I also wan tto remove this for this dataset in case we want to do surface-based analyses.
```
The batch script would look like the following, but keep in mind that you may need to adjust the memory capacity based on how much data each node needs to process.

```bash
#!/bin/bash
#SBATCH --job-name=run_fmriprep_01
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --array=0-92
#SBATCH --mem=16G
#SBATCH --output=~/Data/${USER}/fmriprep_workshop/outputAndErrors/run_fmriprep_01_%A_%a.out 
#SBATCH --error=~/Data/${USER}/fmriprep_workshop/outputAndErrors/run_fmriprep_01_%A_%a.err

SUBJECT_LIST=('sub-MSC01' 'sub-MSC02' 'sub-MSC03' 'sub-MSC04' 'sub-MSC05' 'sub-MSC06' 'sub-MSC07' 'sub-MSC08' 'sub-MSC09' 'sub-MSC10')
SUBJECT=${SUBJECT_LIST[${SLURM_ARRAY_TASK_ID}]}

BIDS_DIR=/sharedapps/LS/psych_imaging/fmriprep_workshop/ds000224-download
PROCESSED_DIR=/sharedapps/LS/psych_imaging/fmriprep_workshop/ds000224-download/derivatives/fmriprep_run_01

apptainer run --mount type=bind,src=$(realpath ~/Data)/${USER}/fmriprep_workshop,dst=/mnt/fmriprep_workshop /sharedapps/LS/psych_imaging/containers/fmriprep-23.1.3.simg $BIDS_DIR $PROCESSED_DIR participant --fs-license-file /mnt/fmriprep_workshop/freesurfer_license.txt --participant_label $SUBJECT --ignore slicetiming --output-spaces MNI152NLin2009cAsym --bold2t1w-dof 9 --return-all-components --skull-strip-template OASIS30ANTs --write-graph --stop-on-first-crash --fs-no-reconall --n_cpus 2
```


You can also open an interactive shell within an instance of the container to look "under the hood" to see what scripts the conatiner is running and what versions of packages those scripts are being run. fMRIPrep is a trusted and well-used pipeline, but it never hurt to double check. To launch an interactive version of the fMRIPrep conatiner image you built, try the following commmand and take a look around! Keep in mind that you can move files out of the container and into your data directory if you want to download them for further inspection. To facilitate that, your `~/Data/${USER}/fmriprep_workshop/` is mounted in the following command to open the interactive session. Remember to start an interactive session on one of the compute nodes before launching your image!

```bash
slurm-shell --mem=8G
apptainer shell --mount type=bind,src=$(realpath ~/Data)/${USER}/fmriprep_workshop,dst=/mnt/fmriprep_workshop fmriprep-23.1.3.simg
```
