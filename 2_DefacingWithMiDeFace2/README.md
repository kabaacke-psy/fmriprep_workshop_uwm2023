## Defacing with MiDeFace2 
With modern preprocessing techniques, it is possible to reconstruct a subject's face from their structural MRI scan with only one line of code. This means that all raw structural neuroimaging data inherently contain PII. In order to ensure confidentiality, it is necessary to obscure the faces and ears of structural scans before they are ready to share. There have been many ways to do this (e.g. PyDeface in Python and mri_deface from FreeSurfer), but most methods either require some tuning to prevent data loss or don't remove enough to prevent facial identification from being possible with what remains. 

However, the most recent version of FreeSurfer includes a new, minimally invasive tool for defacing images, [MiDeFace2](https://surfer.nmr.mgh.harvard.edu/fswiki/MiDeFace2) which seems to work very well. We will go through an example of running this process on one of the structural scans in the sample dataset used in the [dicom2bids tutorial](). 

### Set up FreeSurfer
Before we can run MiDeFace2, we need to make sure the correct version of FreeSurfer is active. The following lines will need to be added to our batch script:

```bash
FREESURFER_HOME=/sharedapps/LS/psych_imaging/freesurfer/7.2.0/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
```

### Run MiDeFace2
The typical syntax for using MiDeFace2 is as follows:

```bash
mideface --i volume.mgz --o volume.defaced.mgz --odir qa
```


For an example of how to run this as an array job, see [deface_01.sbatch](./deface_01.sbatch). You can submit this job with the `sbatch` command once you modify it to suit your dataset.

### Inspect the Results
We can use freeview to inspect the results of this process. To do this, first log into the visual node and source the appropriate version of FreeSurfer as above. Next use the [...]