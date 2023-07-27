# DICOM to BIDS conversion 
These days there are a lot of ways to convert raw DICOM files into .nii or .nii.gz format. Keeping with the theme of efficiency and programmatic methods, I will be covering the use of a Python tool, [dcm2bids](https://unfmontreal.github.io/Dcm2Bids/), which converts most (see the exceptions listed here) DICOM files without error **and** automatically generates .JSON sidecar files using the header information. The following steps are based on [first-steps](https://unfmontreal.github.io/Dcm2Bids/docs/tutorial/first-steps/) tutorial provided by the creators of this package. Please direct any credit to them and their excellent documentation. 

I also strongly reccomend taking a look at the [section on using this process in Andy's Brain Book](https://andysbrainbook.readthedocs.io/en/latest/OpenScience/OS/BIDS_Overview.html). 

*If you run into issues or want more information on these steps, I recommend checking out the original version of the documentation for whatever version you are using.*

The first section covers the steps required to [set up your Conda environment on Mortimer](./1-0_CondaPythonSetup/). These are specific to the Mortimer system, and you should consult a more generic guide or contact your system administrator if you are not using the UWM Mortimer system.

The second second section covers [use of dcm2bids](./1-1_UsingDcm2bids/) and contains some optional Python scripts for handling large and/or messy data.