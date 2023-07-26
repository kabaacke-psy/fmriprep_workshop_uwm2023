# DICOM to BIDS conversion
These days there are a lot of ways to convert raw DICOM files into .nii or .nii.gz format. Keeping with the theme of efficiency and programmatic methods, I will be covering the use of a Python tool, [dcm2bids](https://unfmontreal.github.io/Dcm2Bids/), which converts most (see the exceptions listed here) DICOM files without error **and** automatically generates .JSON sidecar files using the header information. The following steps are based on [first-steps](https://unfmontreal.github.io/Dcm2Bids/docs/tutorial/first-steps/) tutorial provided by the creators of this package. Please direct any credit to them and their excellent documentation. 

I also strongly reccomend taking a look at the [section on using this process in Andy's Brain Book](https://andysbrainbook.readthedocs.io/en/latest/OpenScience/OS/BIDS_Overview.html). 

*If you run into issues or want more information on these steps, I recommend checking out the original version.*

After activating the correct conda environment, you can view some of the options of this function using the following command.

```bash
dcm2bids --help
```