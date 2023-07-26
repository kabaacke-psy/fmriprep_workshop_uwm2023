# Commonly Used Commands
There are **A LOT** of commands you can use within an environment like Mortimer. I reccomend keeping a cheet sheet nearby for whatever OS you are using. When the cheat sheet is not enough, be sure to include your OS when searching for solutions. You can use `cat /etc/os-release` to view information about your OS. Mortimer is currently running CentOS-7. This is a relatively old distribution, but is still widely used for its stability and compatibility. As a result, you should be able to reliably find solutions with a well worded web-search.

Bash is a shell scripting language used by many systems. When working on a system like Mortimer, bash will be your primary way of navigating and performing different operations. Slurm is the job management system Mortimer uses. Most commands have a variety of flags to modify what they do. 

For this workshop, it may be helpful to have the commands below open in a side tab if you are not familiar with bash or slurm commands. These **are not** the formal deffinitions; these are abbreviated and re-worded with some commentary in order to provide an accessible starting point. If you would like to view the full documentation, use the `--help` flag. For example, `cd --help` will tell you more about the cd command.

Bash is a shell scripting language used by many systems. When working on a system like Mortimer, bash will be your primary way of navigating and performing different operations. Most command also have a variety of flags to modify what they do. Almost all commands will have a `--help` flag which you can use to get more information about their use.

## Bash Commands
Bash is a shell scripting language used by many systems. When working on a system like Mortimer, bash will be your primary way of navigating and performing different operations. Most command also have a variety of flags to modify what they do. Almost all commands will have a `--help` flag which you can use to get more information about their use. Below are a few of the most frequently used commands and some of their commonly used flags. This is not an exhaustive list. These are not the formal definitions of these commands.

- `cd`: Used to change directory. Typically you should specify the relative or full path to the directory you want to change to after this command. If no directory is specified, it will default to your home directory (`~/`). `..` can also be used to go up one level in your directory tree. This can be chained; `cd ../../..` will take you up three levels in the directory tree. You can also reference environmental variables using this command. For example, you can use `cd $OLDPWD` to change to the directory you were before your last CD command.
- `pwd`: Print working directory.
- `ls`: This command lists the contents of the directory you are currently in. 
    - `-a` (all) will cause `ls` to display hidden files and folders.
    - `-l` (long) will show more information about the files/folders than just their name.
    - `-h` (human) will make the information provided by `-l` to be in a more 'human readable' form.
- `echo`: This command prints whatever follows it to the console. This is particularly useful if you want to print out variables. For example, if you want to print the directories included in your `PATH` variable, you could type `echo $PATH`.
- `export`: This is used to assign a variable on the environmental level. If you want to store a variable as `VAR1=SomeVarHere`, you could refer to it later in your script as `$VAR1`. However, it will not be visible to other programs unless you also `export` that variable. One of the most common applications of this command is to add a directory to your `PATH` variable so your interpreter will look for your application in that directory. For example, you can add the path to FSL by using the following command: `export PATH=$PATH:/sharedapps/LS/psych_imaging/fsl/6.0.4/bin/`
- `mkdir`: Make a new directory.
- `mv`: Move a file or directory to a new location.
- `cp`: Copy a file to a new location.
    - `-r`: (Recursive) use this to move a folder rather than a file
- `du`: Summarize disk usage of each FILE, recursively for directories.
    - `-s`: (Summary) Display only a total for each argument.
    - `-h`: (Human readable) Show values in human readable format.
- `rm`: Remove a file
    - `-r`: (Recursive) Remove a directory 
- `cat`: Print the contents of a file to the terminal.
- `head`: Print the first few lines of a file. Use a number to specify the number of lines to show.
- `tail`: Same as head, but with the end of the file.
- `screen`: Start a screen terminal session which you can resume at a later date.
    - `-S`: Use to specify the name of the screen session you want to start.
    - `-r`: Use to resume a session rather than create one.
- `ln`: Create a link to another file/location
    - `-s`: Create a symbolic link rather than a hard link
      - *This is almost always the preferred option in my experience.*
- `grep`: Search for a REGEX pattern within a file, list of files, or other string input

## Slurm
Clusters provide a wonderful way to parallelize computational operations with minimal effort by linking many computers together. Our cluster uses one of the most widely used and well documented cluster management and job scheduling systems, [Slurm](https://slurm.schedmd.com/overview.html). Slurm is what we will use to submit and monitor our jobs, where jobs are discrete computational processes defined within a bash script (usually with the *.sbatch* file extension). Slurm will use the information we provide to queue up our jobs and assign computational resources from the machines in the cluster as they become available. The resources allocated to a given job are collectively called a node. There can be many nodes on a single computer, but nodes are usually not spread across machines in order to maximize efficiency. Below are a few of the commands and key flags which can be used in the Slurm environment.

- `slurm-shell`: This command starts up an interactive shell on a node in the cluster. This is perfect for if you wan to test out your script line by line and see what the node sees.
    - You can use most of the same flags here as in `sbatch`. Please see that section for more details.
- [`squeue`](https://slurm.schedmd.com/squeue.html): This allows you to inspect the current job queue.
    -`-u` will allow you to filter the jobs by username. For example, `squeue -u $USER` will only show nodes which were created using your username.
- [`sbatch`](https://slurm.schedmd.com/sbatch.html): This command (followed by the path to a batch script) is used to launch a job on the cluster. 
    - `--mem=`: Allows you to specify how much memory your node will need. E.x. `--mem=6G` will ensure that all nodes have 6 GB of memory to work with.
    - `--job-name=`: Allows you to specify the name of your job.
    - `--cpus-per-task=`: Specify the number of CPUs per node. If you are running something which is parallelized within the job (like the recon-all option in fMRI Prep), you may want more than one CPU per node.
    - `--array=`: Often you will want to start many jobs at once with the same parameters. Using the array option allows you to do so by providing a range of numbers (0-100) or a pre-defined list. The array values can then be used to specify which iteration you want to run within each node (more on this later).
    - `--output=`: Any printed output will be saved to a file specified at the output location. I recommend including `%A` and `%a` in the file name. These will include the Job ID and the array index, respectively, in the filename.
    - `--error=`: Any errors will be printed to the file specified. As with the --output flag, including `%A` and `%a` in the filename is recommended as it will allow for files to be created for every job in an array without duplication.

