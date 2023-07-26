# Using dcm2bids

## Creating the BIDS Structure
This package can also be used to create a BIDS compliant data structure for us to put our data into. If you would like to learn more about BIDS, I strongly recommend looking at the [BIDS Starter Kit](https://bids-standard.github.io/bids-starter-kit/index.html). To create the top-level folder structure and metadata files, we will use the `scaffold` command. First navigate to your data directory where you want your BIDS data to be stored, then use the following code, where DATASET_NAME is the name you want to use for your BIDS folder.

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

You may also want to preserve the names of the folders rather than just the names of the files. Below is an example of a Slurm array job script to do just that. 

```bash
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

The following Python script iterates through a file structure containing the output from `dcm2bids_helper` and consolidates the metadata from all of the temporary .JSON files into a single spreadsheet. This can be a great way to check to make sure the scans are labeled correctly and to verify that no personally identifiable information (PII) is accidentally transferred from the DICOM files to your BIDS data structure. 

```python
# import necessary packages
## Pandas allows for easy manipulation of dataframes
import pandas as pd
## json is used to read the metadata .JSON objects
import json
## os allows us to interface with the operating system in a generic way
## glob is a helpful file search tool
import os, glob

# Assign the USER environment variable as a Python variable
USER = os.getenv('USER')
# Set the path of the project in question
project_path = f'~/Data/{USER}/fmriprep_workshop/'
# Specify the folder containing the output of the dicm2bids_helper output
raw_folder = f'{project_path}RawNifti'

# Create an empty list to store all of the metadata objects in
scan_dfs = []
# Create a for loop to iterate through the folders in the output folder and use os.listdir() to fetch the list of folders/files as a list
for subject_id in os.listdir(raw_folder):
  # Use the subject_id to create a string variable for the path to the subject's folder 
  subject_folder = f'{raw_folder}/{subject_id}'
  # Iterate through scan folders within the subject's folder
  for scan_id in os.listdir(subject_folder):
    # Create a string variable to specify the path to the scan folder
    scan_dir = f'{subject_folder}/{scan_id}'
    # This may fail if an earlier step failed. We don't want that to stop the script, so it is in a "try/except" block.
    #   The script will "try" everything in the try section and will only execute the "except" block is only executed if an error arises.
    try:
      # Use glob to search for files ending in .json within the scan_dir
      ## glob.glob() by default returns a list. This script is meant to target folders with only one scan, so the list will only be one object long. the [0] at the end selects that first object in the list
      json_path = glob.glob(f'{scan_dir}/tmp_dcm2bids/helper/*.json')[0]
      # We can then use json to open the json file and save it as a Python dictionary.
      metadata_dict = json.load(open(json_path))
      # Dictionary objects are not ideal for concatenating because the values can be of different dimensions.
      # This next bit converts all of the key-value pairs into header and single string values to put into a dataframe.
      for k in metadata_dict.keys():
        # Check to see if the type of the value is compatible with a dataframe. 
        if type(metadata_dict[k])!=type('str') and type(metadata_dict[k])!=type(0):
          # If the value type is not compatible, cast it as a string
          metadata_dict[k] = str(metadata_dict[k])
        # Convert the object value into a list with only one entry (the initial value)
        metadata_dict[k] = [metadata_dict[k]]
      # convert the dictionary object into a dataframe with pandas with the keys of the dictionary as the column headers
      metadata_df = pd.DataFrame.from_dict(metadata_dict, orient='columns')
      # Assign values which are not in the DICOM to the dataframe for easy reference
      metadata_df['SubjectID'] = subject_id
      metadata_df['Scan'] = scan_id
      # Append the dataframe with to our list of metadata dataframes
      scan_dfs.append(metadata_df)
    except Exception as e:
      # If there is an error, print it and the directory where the error occurred 
      print(f'Error fetching data from {scan_dir}: {e}')
      # Create a "dummy" metadata dictionary so that there is still a slot for the scan directory in the output
      metadata_dict = {
        'SubjectID':[subject_id],
        'Scan':[scan_id]
      }
      metadata_df = pd.DataFrame.from_dict(metadata_dict, orient='columns')
      # Append the "dummy" dataframe to the list of metadata dataframes
      scan_dfs.append(metadata_df)

# Concatenate the dataframes. This defaults to concatenating rows (rather than columns)
full_metadata = pd.concat(scan_dfs)
# Save the output dataframe to a .CSV file
full_metadata.to_csv(f'{project_path}target_scan_metadata.csv', index=False)
```

The .CSV file which appears in the `project_path` will contain headers for each of the DICOM values present across any scans with a row entry for every .JSON file it finds. This way, you can preview what information would be present in the sidecar files without any other intervention.

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

For the sample dataset, you can create your own config file for these scans, or you can use the example provided in this folder.

## Programmatic dcm2bids Config Creation
If you want to create your configuration files on a subject-by-subject basis but don't want to spend valuable time making those configuration files by hand, you can use the following Python script to complete the process based on a spreadsheet of header information like the one created in [Metadata Consolidation]().

The script below uses a combination of `"SeriesDescription"` and `"SeriesNumber"` as present in the metadata spreadsheet so assign flexible criteria on a scan-by-scan basis for each scan in the dataset. Additionally, this script always removes the `"AcquisitionTime"` value to prevent any possible breach of PII.

```python
# import necessary packages
## Pandas allows for easy manipulation of dataframes
import pandas as pd
## json is used to read the metadata .JSON objects
import os, json

# Assign the USER environment variable as a Python variable
USER = os.getenv('USER')
# Set the path of the project in question
project_path = f'~/Data/{USER}/fmriprep_workshop/'
# Specify the folder containing the output of the dicm2bids_helper output
raw_folder = f'{project_path}RawNifti'
# Open the metadata spreadsheet
reference_df = pd.read_csv(f'{project_path}target_scan_metadata.csv')
# Iterate through each subject
for subject_id in reference_df['SubjectID'].unique():
  # Create a dictionary with a 'descriptions' key with an empty list as the value 
  subject_config = {
    'descriptions':[]
  }
  # Subset the dataframe to only include rows belonging to the target subject
  subject_df = reference_df[reference_df['SubjectID']==subject_id]
  # Iterate through the rows (representing scans) in the subset dataframe
  for index, row in subject_df.iterrows():
    # Identify which scan was which based on the 'Scan' column
    if row['Scan']=='Rest1':
      scan_description = {
        'dataType':'func',
        'modalityLabel':'bold',
        'customLabels':'task-rest_run-01',
        # 'session':'',
        'criteria':{
          'SeriesDescription':row['SeriesDescription'],
          'SeriesNumber':int(row['SeriesNumber'])
        },
        'sidecarChanges':{
          'AcquisitionTime':None
        }
      }
    elif row['Scan']=='Rest2':
      scan_description = {
        'dataType':'func',
        'modalityLabel':'bold',
        'customLabels':'task-rest_run-02',
        # 'session':'',
        'criteria':{
          'SeriesDescription':row['SeriesDescription'],
          'SeriesNumber':int(row['SeriesNumber'])
        },
        'sidecarChanges':{
          'AcquisitionTime':None
        }
      }
    elif row['Scan']=='SPGR1':
      scan_description = {
        'dataType':'anat',
        'modalityLabel':'T1w',
        'customLabels':'run-01',
        # 'session':'',
        'criteria':{
          'SeriesDescription':row['SeriesDescription'],
          'SeriesNumber':int(row['SeriesNumber'])
        },
        'sidecarChanges':{
          'AcquisitionTime':None
        }
      }
    elif row['Scan']=='SPGR2':
      scan_description = {
        'dataType':'anat',
        'modalityLabel':'T1w',
        'customLabels':'run-02',
        # 'session':'',
        'criteria':{
          'SeriesDescription':row['SeriesDescription'],
          'SeriesNumber':int(row['SeriesNumber'])
        },
        'sidecarChanges':{
          'AcquisitionTime':None
        }
      }
    elif row['Scan']=='SPGR3':
      scan_description = {
        'dataType':'anat',
        'modalityLabel':'T1w',
        'customLabels':'run-03',
        # 'session':'',
        'criteria':{
          'SeriesDescription':row['SeriesDescription'],
          'SeriesNumber':int(row['SeriesNumber'])
        },
        'sidecarChanges':{
          'AcquisitionTime':None
        }
      }
    elif row['Scan']=='SPGR4':
      scan_description = {
        'dataType':'anat',
        'modalityLabel':'T1w',
        'customLabels':'run-04',
        # 'session':'',
        'criteria':{
          'SeriesDescription':row['SeriesDescription'],
          'SeriesNumber':int(row['SeriesNumber'])
        },
        'sidecarChanges':{
          'AcquisitionTime':None
        }
      }
    elif row['Scan']=='SPGR5':
      scan_description = {
        'dataType':'anat',
        'modalityLabel':'T1w',
        'customLabels':'run-05',
        # 'session':'',
        'criteria':{
          'SeriesDescription':row['SeriesDescription'],
          'SeriesNumber':int(row['SeriesNumber'])
        },
        'sidecarChanges':{
          'AcquisitionTime':None
        }
      }
    subject_config['descriptions'].append(scan_description)
  # Generate a filename for the subject-level JSON
  json_fname = f'{raw_folder}/{subject_id}/{subject_id}_dcm2bids-config.json'
  # Save the JSON to a file
  with open(json_fname,'w') as outfile:
    json.dump(subject_config, outfile)
  # Print a message so you know it's all working
  print(f'{subject_id} config file created with {len(subject_config["descriptions"])} scans included: {json_fname}')
```

*When you move on to [Run dcm2bids](), be sure to reference the json files on a subject-by-subject basis.*

## Run dcm2bids
For instructions on how to run `dcm2bids` on the example data, please see the appropriate section in the [First-Steps](https://unfmontreal.github.io/Dcm2Bids/2.1.9/tutorial/first-steps/) tutorial. If you created your config files programmatically using the script in [Programmatic dcm2bids Config Creation](), or if you want to see an example of this process run on a cluster environment, the below is an example of an array batch script which parallelizes the process on the level of the subject.

```bash
#!/bin/bash
#SBATCH --job-name=dcm2bids_conversion_01
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=0-1
#SBATCH --mem=3G
#SBATCH --output=~/Data/${USER}/fmriprep_workshop/outputAndErrors/dcm2bids_conversion_01-%A_%a.out 
#SBATCH --error=~/Data/${USER}/fmriprep_workshop/outputAndErrors/dcm2bids_conversion_01-%A_%a.err

. /sharedapps/LS/conda/miniconda/etc/profile.d/conda.sh
conda activate
conda activate ~/Data/kbaacke/${USER}/dcm2bids-env

SUBJECT_LIST=($(ls /sharedapps/LS/psych_imaging/fmriprep_workshop/dcm_qa_nih-master/In/))
SUBJECT=${SUBJECT_LIST[${SLURM_ARRAY_TASK_ID}]}
OUTPUT_DIR=~/Data/${USER}/fmriprep_workshop/bids_example_01/
SUBJECT_JSON=${SUBJECT_DIR}/${SUBJECT}_dcm2bids-config.json
SUBJECT_DIR=/sharedapps/LS/psych_imaging/fmriprep_workshop/dcm_qa_nih-master/In/$SUBJECT

dcm2bids -d $SUBJECT_DIR -p $SUBJECT -c $SUBJECT_JSON -s 01 -o $OUTPUT_DIR
echo "${SUBJECT} conversion complete."
```
The array of jobs can be sent to the cluster que using the following `sbatch`:
```bash
sbatch /sharedapps/LS/psych_imaging/fmriprep_workshop/DICOM_to_BIDS_Conversion/dcm2bids_conversion_01.sbatch
```