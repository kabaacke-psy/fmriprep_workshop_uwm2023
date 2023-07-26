# Conda/Python Setup
[Python](https://www.python.org/) is a freely available and relatively intuitive programming language commonly used for a wide variety of purposes. [Conda](https://docs.conda.io/en/latest/) is a freely available package management system and environment management system. We will primarily be using Conda for Python environment setup, but it is important to keep in mind that it can do much more. 

## Creating a conda environment
First we need to create log into an environment suitable to accomplish our tasks. You can complete the following steps on the visual node or a compute node. To use a compute node, enter the following command:

```bash
slurm-shell --mem=4G
```

You may notice that this takes a few moments to complete. The SLURM job scheduler is looking for an idle node to assign to you. Because we are configuring/installing, there is no need to specify memory or CPU requirements for the interactive node. Once the command line returns to normal, activate conda using one of the two methods listed below. 

## Activating Conda
To activate conda on the cluster, you need to run `. /sharedapps/LS/conda/miniconda/etc/profile.d/conda.sh` followed by `conda activate` You can do this by typing the following into your console window:

```bash
. /sharedapps/LS/conda/miniconda/etc/profile.d/conda.sh
conda activate
```
If don't want to memorize this path and want to save time entering this in every time, you can create a function in the *.bashrc* in your home directory. The syntax is as follows:

```bash
function setup_conda(){
	. /sharedapps/LS/conda/miniconda/etc/profile.d/conda.sh
	conda activate
}
export -f setup_conda
```

The first line instantiates the function, the middle two lines define what the function does, and the last line exports the command so that you can use the user defined function, `setup_conda`, when you log in to activate conda.

Next, we need to create a new conda environment so that our package installations don't interfere with other users' experience. I recommend creating a directory specifically for your conda environments in your data directory. For example:

```bash
mkdir ~/Data/${USER}/conda_envs
```

The `${USER}` will use the environment vairbale `USER` which is automatically set when you log in. There is no need to manually insert your username into this command.

Now we are ready to create a new conda environment. We will use the *-p* flag to specify a full path to where we want our environemnt to be stored. **You will not be able to run the command without this flag because you should not have write permissions to the default location of conda environments on the cluster.**

```bash
# This may take a while.
conda create -p ~/Data/${USER}/conda_envs/dcm2bids-env
```

This will create an environment named `dcm2bids-env`. You can all your environments whatever you want, but it is good practice to make the names meaningful. Now that this environment has been created, the full path to the environment will be saved in `~/.conda/environments.txt`. If you ever want to check what environments you have created, you can check that file or type one of the followin commands:

```bash
conda env list
conda info --envs
```

Before we activate our new environment and start installing things, we will need to add a the conda-forge channel to our Conda configuration. This can be accomplished by entering the following into your terminal:

```bash
conda config --append channels conda-forge
```

*Note*: If you would like to see what channels you have configured, see the *channels* section of your `~/.condarc`.

Now we are ready to activate our environment and begin installing packages. To activate the environment, use the activate command:

```bash
conda activate ~/Data/${USER}/conda_envs/dcm2bids-env
```

For our purposes in this section, we should only need three packages: pandas, dcm2niix, and dcm2bids. You can install them using the basic install command if your environment is active.

```bash
# This may also take a while.
conda install pandas dcm2niix dcm2bids
```
Once this is complete, you are ready to move on to [Using dcm2bids](../UsingDcm2bids/).