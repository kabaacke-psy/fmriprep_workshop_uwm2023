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
project_path = f'/home/{USER}/Data/{USER}/fmriprep_workshop/'
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