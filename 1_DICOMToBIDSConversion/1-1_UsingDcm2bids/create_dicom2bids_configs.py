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
reference_df = pd.read_csv(f'{project_path}target_scan_metadata_editted.csv')
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
    print(row)
    # Identify which scan was which based on the 'Scan' column
    if row['Scan']=='mr_0003':
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
    elif row['Scan']=='mr_0004':
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
    elif row['Scan']=='mr_0005':
      scan_description = {
        'dataType':'func',
        'modalityLabel':'bold',
        'customLabels':'task-rest_run-03',
        # 'session':'',
        'criteria':{
          'SeriesDescription':row['SeriesDescription'],
          'SeriesNumber':int(row['SeriesNumber'])
        },
        'sidecarChanges':{
          'AcquisitionTime':None
        }
      }
    elif row['Scan']=='mr_0006':
      scan_description = {
        'dataType':'func',
        'modalityLabel':'bold',
        'customLabels':'task-rest_run-04',
        # 'session':'',
        'criteria':{
          'SeriesDescription':row['SeriesDescription'],
          'SeriesNumber':int(row['SeriesNumber'])
        },
        'sidecarChanges':{
          'AcquisitionTime':None
        }
      }
    elif row['Scan']=='mr_0007':
      scan_description = {
        'dataType':'func',
        'modalityLabel':'bold',
        'customLabels':'task-rest_run-05',
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