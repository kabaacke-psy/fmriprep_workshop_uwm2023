# Using dcm2bids

## Creating the BIDS Structure
Along with performing the conversion from DICOM to NIFTI, the `dcm2bids` package can also be used to create a BIDS compliant data structure for us to put our data into. If you would like to learn more about BIDS, I strongly recommend looking at the [BIDS Starter Kit](https://bids-standard.github.io/bids-starter-kit/index.html). To create the top-level folder structure and metadata files, we will use the `scaffold` command. First navigate to your data directory where you want your BIDS data to be stored, then use the following code, where DATASET_NAME is the name you want to use for your BIDS folder.

```bash
dcm2bids_scaffold -o bids_example_01
```

This will generate the following template files and directories:

|File/Folder|Description|
|---|---|
|[CHANGES](https://bids-specification.readthedocs.io/en/stable/03-modality-agnostic-files.html#changes)|Text file containing documentation of changes made|
|[dataset_description.json](https://bids-specification.readthedocs.io/en/stable/03-modality-agnostic-files.html#dataset_descriptionjson)|JSON file containing information about the dataset|
|[README](https://bids-specification.readthedocs.io/en/stable/glossary.html#readme-files)|Text file describing the dataset and any essential details|
|[participants.tsv](https://bids-specification.readthedocs.io/en/stable/03-modality-agnostic-files.html#participants-file)|File containing high-level information on subjects (e.g. age, sex, handedness, experimental group).|
|[participants.json](https://bids-specification.readthedocs.io/en/stable/03-modality-agnostic-files.html#participants-file)|Sidecar information file containing information about the columns and values contained in the *participants.tsv* file.|
|[code/](https://bids-specification.readthedocs.io/en/stable/03-modality-agnostic-files.html#code)|Directory to store scripts used to prepare the dataset (optional).|
|[sourcedata/](https://bids-specification.readthedocs.io/en/stable/glossary.html#sourcedata-files)|Directrory to store data before harmonization or conversion (e.g. raw DICOM files or E-Prime event logs). **If storing DICOM files or any other identifiable data here, be sure to include it in a .bidsignore file.**|
|[derivatives/](https://bids-specification.readthedocs.io/en/stable/05-derivatives/01-introduction.html)|Directory to store preprocessed or otherwise derivative data. Informattion about the pipeline used and the full set of information from the top level `dataset_description.json` file should be included in `derivatives/<pipeline_name>/dataset_description.json`. See the[ BIDS specification documentation](derivatives/<pipeline_name>/dataset_description.json) for details.|

## Using dcm2bids_helper

Before converting and migrating the data into the BIDS directory, I recommend previewing the metadata contained within the DICOM files. Thankfully, dcm2bids provides a useful function for just this purpose: `dcm2bids_helper`. You can preview the options for this command using the `--help` flag. The two options to be aware of for this function are the required `-d` to specify the input directory and the optional `-o` to specify the output directory. If you do not specify an output location with `-o`, dcm2bids will create the following directory structure wherever you run the command `tmp_dcm2bids/helper`. 

For the sake of simplicity, it is recommended that you start with only a single subject's data when running this on a large dataset. To try this out on the full set of sample data provided by the NIH, run the following command: 

```bash
dcm2bids_helper -d /sharedapps/LS/psych_imaging/fmriprep_workshop/dcm_qa_nih-master/In/ -o ~/Data/${USER}/fmriprep_workshop/RawNifti/
```

To run this same process on only one of the scans, simply add the name of the folder containing the DICOM files you want to target:

```bash
dcm2bids_helper -d /sharedapps/LS/psych_imaging/fmriprep_workshop/dcm_qa_nih-master/In/{NAME_OF_FOLDER} -o ~/Data/${USER}/fmriprep_workshop/RawNifti/{NAME_OF_FOLDER}
```

You may also want to preserve the names of the folders rather than just the names of the files. See [dcm2bids_helper_01.sbatch](./dcm2bids_helper_01.sbatch) for an example of this. You can submit this array job to the cluster using 
```bash
sbatch /sharedapps/LS/psych_info/fmriprep_workshop/
```

You may have learned that `#` can be used to leave comments in a shell script. While this is true, `#` is also used to specify attributes of a script or to pass additional arguments to the command used to run a script.
 
The first line (`#!/bin/bash`) is called a (shebang)[https://en.wikipedia.org/wiki/Shebang_%28Unix%29]. This tells our machine which interpreter to use when executing this script.

The following five lines all specify the values for optional flags to use when we call `sbatch`. To preview all of the possible options, use `sbatch --help`. In this case, I named the job with `--job-name`, specified the number of tasks and CPUs with `--ntasks` and `--cpus-per-task`, and specified the amount of memory per needed per job with `--mem`. The final argument line specifies that this is an array job which will be run across 5 identical nodes. Not that I include the starting value of `0` because array jobs without a starting value will start at `1`. The values in the `array` argument wil be used to set the `SLURM_ARRAY_TASK_ID` environment variable on a per task basis. This script uses `SLURM_ARRAY_TASK_ID` to index within a list, and list indices start at `0`. Using `--array=5` would skip the first folder and would return an error for the task with the `SLURM_ARRAY_TASK_ID` of 5 as there are only 5 folders in our raw DICOM directory.

You can also include these when flags you call the job, but I have found that it is easier to keep track of them if they are in the batch script.

The next three lines are used to activate conda and the environment we created earlier in the tutorial. Even if you have the environment activated on your current session, it will not be active in the jobs, as they are treated as new sessions.

```bash
. /sharedapps/LS/conda/miniconda/etc/profile.d/conda.sh
conda activate
conda activate ~/Data/${USER}/conda_envs/dcm2bids-env
```

There are **many** ways of specifying which subject of folder to run using the `SLURM_ARRAY_TASK_ID`. If you want more flexibility, I recommend exploring those options. However, the method used above is simple and extremely generalizable. The first step in the process is to create a list of folder names to iterate through. Generally, these are also subject IDs, so I assign them to the variable `$SUBJECT_LIST` here.

```bash
SUBJECT_LIST=($(ls /sharedapps/LS/psych_imaging/fmriprep_workshop/dcm_qa_nih-master/In/))
```
This passes the output of the `ls` command to a list environnement variable. You can preview the contents of this list with `echo $SUBJECT_LIST`. 

```bash
SUBJECT=${SUBJECT_LIST[${SLURM_ARRAY_TASK_ID}]}
```

This uses the intiger value assigned to the `$SLURM_ARRAY_TASK_ID` as an index to select a single subject ID from our `$SUBJECT_LIST` and assign it to the new variable `$SUBJECT`. This new variable can then be used to assign the correct input and output file paths for each of our task runs.

## Inspecting Metadata

Now that the .JSON files have been created, you can inspect them to wee which pieces of metadata can be used to reliably identify which scan belongs to which session/run. To compare .JSON files side-by-side, you can use the `diff` command with the `--side-by-side` flag.

```bash
diff --side-by-side tmp_dcm2bids/helper/"003_In_EPI_PE=AP_20180918121230.json" tmp_dcm2bids/helper/"004_In_EPI_PE=PA_20180918121230.json"
```

If you have many scans to inspect, I suggest using a tool like Python to consolidate the information from the JSON files into a spreadsheet for easy inspection. For an example of how to do so, please see [Metadata Consolidation]().

## Metadata consolidation (optional)

If your data is well organized and you know exactly which scan files to use without question, feel free to skip this section. however, if your data is messy and you want to double check that no mistakes were made when labeling the scan runs, you may find this helpful. 

[consolidate_metadata.py](./consolidate_metadata.py) iterates through a file structure containing the output from `dcm2bids_helper` and consolidates the metadata from all of the temporary .JSON files into a single spreadsheet. This can be a great way to check to make sure the scans are labeled correctly and to verify that no personally identifiable information (PII) is accidentally transferred from the DICOM files to your BIDS data structure. 

The .CSV file which appears in the `project_path` after this script runs will contain headers for each of the DICOM values present across any scans with a row entry for every .JSON file it finds. This way, you can preview what information would be present in the sidecar files without any other intervention.

## dcm2bids Configuration

Not that we have previewed the metadata embedded in the DICOM files (and verified the scans based on that metadata), it is time to create configuration files for dcm2bids. The full walk-through on how to create a config file can be found [here](https://unfmontreal.github.io/Dcm2Bids/docs/how-to/create-config-file/). The configuration file will tell dcm2bids where to put each scan within the BIDS directory and how to handle any naming conventions. We need a single field or a combination of fields which allow for unique identification of each type DICOM series within the directory in question. For example, only searching for the pattern `"Axial EPI-FMRI*"` in the `"SeriesDescription"` field would not be specific enough in the context of the sample dataset because it would match more than one scan. 

```bash
grep "Axial EPI-FMRI*" tmp_dcm2bids/helper/*.json
```

Using the full string will work, so we can use that as the criteria by to match by in our configuration file.

```json hl_lines="3-10"
{
  "descriptions": [
    {
      "dataType": "func",
      "modalityLabel": "bold",
      "customLabels": "task-rest",
      "criteria": {
        "SeriesDescription": "Axial EPI-FMRI (Interleaved I to S)*",
        "sidecarChanges": {
          "TaskName": "rest"
        }
      }
    }
  ]
}
```

We can then go through the other scans in the folder, and add an entry in `"descriptions"` for each of them. Please refer to the [First-Steps](https://unfmontreal.github.io/Dcm2Bids/2.1.9/tutorial/first-steps/) tutorial provided by the creators of dcm2bids for more information on assigning field maps and important tips on avoiding filenames as criteria and the recommended use of a JSON validator.

**Don't forget to remove PII!**

*If you have any data in your DICOM headers which could possibly be used to identify your research participants, be sure to set that value to `null` in `sidecarChanges`.*

```json hl_lines="3-11"
{
  "descriptions": [
    {
      "dataType": "func",
      "modalityLabel": "bold",
      "customLabels": "task-rest",
      "criteria": {
        "SeriesDescription": "Axial EPI-FMRI (Interleaved I to S)*",
        "sidecarChanges": {
          "TaskName": "rest",
          "AcquisitionTime":null
        }
      }
    }
  ]
}
```

If the header information is consistent across participants, you can reference the same config file multiple times. If the config files need to be created dynamically based on a spreadsheet like the one created in the optional [Metadata Consolidation]() step, see [Programmatic dcm2bids Config Creation]() for a possibly time-saving option using Python. 

For the sample dataset, you can create your own config file for these scans, or you can use the example [provided]().

## Programmatic dcm2bids Config Creation
If you want to create your configuration files on a subject-by-subject basis but don't want to spend valuable time making those configuration files by hand, you can use the following Python script to complete the process based on a spreadsheet of header information like the one created in [consolidate_metadata.py](./consolidate_metadata.py).

The script below uses a combination of `"SeriesDescription"` and `"SeriesNumber"` as present in the metadata spreadsheet so assign flexible criteria on a scan-by-scan basis for each scan in the dataset. Additionally, this script always removes the `"AcquisitionTime"` value to prevent any possible breach of PII.

*When you move on to [Run dcm2bids](), be sure to reference the json files on a subject-by-subject basis.*

## Run dcm2bids
For instructions on how to run `dcm2bids` on the example data, please see the appropriate section in the [First-Steps](https://unfmontreal.github.io/Dcm2Bids/2.1.9/tutorial/first-steps/) tutorial. If you created your config files programmatically using the script in [Programmatic dcm2bids Config Creation](), or if you want to see an example of this process run on a cluster environment, [dcm2bids_conversion_01.sbatch](./dcm2bids_conversion_01.sbatch) an example of an array batch script which parallelizes the process on the level of the subject.

The array of jobs can be sent to the cluster que using the following `sbatch`:
```bash
sbatch /sharedapps/LS/psych_imaging/fmriprep_workshop/DICOM_to_BIDS_Conversion/dcm2bids_conversion_01.sbatch
```