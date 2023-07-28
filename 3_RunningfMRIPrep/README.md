# Running fMRIPrep 
[fMRIPrep](https://fmriprep.org/en/stable/) extremely well documented, and I encourage you to reference the documentation (*specific to the version you are using*) when deciding which optional flags to use when running fMRIPrep. This tutorial follows the documentation provided by the creators of fMRIPrep for [Executing with Singularity](https://www.nipreps.org/apps/singularity/) in the context of the Mortimer System.

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
We will be using a containerized version of fMRIPrep. This makes our processing less resource-denendant, more reproducible, more portable, and far easier to set up. For the purposes of this workshop, containers are like virtual machines, but better. If you would like to learn more about container technologies, there are a lot of amazing videos esplaining them in a variety of contexts. I was introduced to this in a different context, but found [Containerization Explained](https://www.youtube.com/watch?v=0qotVMX-J5s) extremely helpful (and brief) at the time.

Once your work directory is set up, you can begin the process of downloading and building the container image of the version of fMRIPrep that you want to use. While we will be using [Apptainer](https://apptainer.org/) to run our containers, we will be downloading the required build files from [DockerHub](https://hub.docker.com/). Singularity has been renamed to Apptainer, but there are still actively maintained forks of Singularity. For our purposes, it is OK to use the terms interchangably. Docker is another container hosting software altogether, but it is less frequently used in cluster environments. Thankfully, Singularity can build images based on Docker container definition files. 

```bash
apptainer build ~/Data/${USER}/fmriprep_workshop/fmriprep-23.1.3.sif docker://nipreps/fmriprep:23.1.3
```
This command pulls the Docker file for version 23.1.3 of fMRRPrep and builds a container image for us to run our analyses on. If you would like to inspect the commands being run to build the container image, you can go to the [corresponding DocherHub page](https://hub.docker.com/layers/nipreps/fmriprep/23.1.3/images/sha256-0d5d42c28cc02adecde8275328e357138e489c107683ac0ae3b3c8cfe45d6272?context=explore) to view the layers in the DockerFile and their file sizes.

## Chosing which options to use
The typical use of fMRIPrep is to run the `run.sh` script which is aliased by default in the container image. Please see the documentation for your version of fMRIPrep for which flags to use in your context. 

Outside of the fMRIPrep options, you may also want to specify some container options. In the example below, one of the example datasets from the `/sharedapps/LS/psych_imaging/fmriprep_workshop` directory is mounted to the image.

```bash
apptainer run \  # Run container instance
    --mount type=bind,src=$(realpath ~/Data)/${USER}/fmriprep_workshop,dst=/mnt/fmriprep_workshop \  # Mount directory containing bids data
    /sharedapps/LS/psych_imaging/containers/fmriprep-23.1.3.sif \ # # Target the container image to run
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
    --fs-no-reconall \  # disable FreeSurfer surface preprocessing. 
```
[run_fmriprep_01.sbatch](./run_fmriprep_01.sbatch) will launch an array job to run all of the subjects in the [UCLA Consortium for Neuropsychiatric Phenomics LA5c Study](https://openneuro.org/datasets/ds000030/versions/00016/) dataset. This script can be easily modified for other datasets, but keep in mind that you may need to adjust the memory capacity based on how much data each node needs to process. You can run this batch script using `sbatch /sharedapps/LS/psych_imaging/fmriprep_workshop/fmriprep_workshop_uwm2023/3_RunningfMRIPrep/run_fmriprep_01.sbatch`

You can also open an interactive shell within an instance of the container to look "under the hood" to see what scripts the conatiner is running and what versions of packages those scripts are being run. fMRIPrep is a trusted and well-used pipeline, but it never hurt to double check. To launch an interactive version of the fMRIPrep conatiner image you built, try the following commmand and take a look around! Keep in mind that you can move files out of the container and into your data directory if you want to download them for further inspection. To facilitate that, your `~/Data/${USER}/fmriprep_workshop/` is mounted in the following command to open the interactive session. Remember to start an interactive session on one of the compute nodes before launching your image!

```bash
slurm-shell --mem=8G
apptainer shell --mount type=bind,src=$(realpath ~/Data)/${USER}/fmriprep_workshop,dst=/mnt/fmriprep_workshop fmriprep-23.1.3.sif
```

When you `run` the container, the `fmriprep` command is run by default. You can preview what this is doing using the following command once you are inside an interactive container.

```bash
# Identify the location of the fmriprep script
which fmriprep
#Print out the contents of the script
cat $(which fmriprep)
```

This is a python script which runs the `main()` function located in the `fmriprep` site package. You can find the specific file containing this function at `/opt/conda/envs/fmriprep/lib/python3.10/site-packages/fmriprep/cli/run.py` If you ever want to dig deeper into what fMRIPrep is doing 'under the hood', you can backtrace from this file. If you want to do this on a local maching, you can copy the contents of `/opt/conda/envs/fmriprep/lib/python3.10/site-packages/fmriprep/` to your data directory before shutting down the container instance.