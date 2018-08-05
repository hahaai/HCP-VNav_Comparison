# HCP and VNav Comparison.
This analysis runs test-retest reliability (ICC) on HCP and VNav sequence.

## 1. Data organization and preparation.

1.1 Brain extraction using 3dSkullstrip

1.2 nu correction and N4 intensition normalization

1.3.1 Registrion to standard using flirt and fnirt, save all the transformation and warp files

1.3.2 Get potial volume estimates (PVE) usign fast


## 2. Using Python scripts to read in each image and then convert to ICC run ready data structure and save date for each voxel.

/data2/Projects/Lei/HCP_VNav_comparision/scripts/ICC_Prep.py

It can save both HCP2VNav and VNav2HCP into different folders.

## 3. Run ICC on each voxel in R in parallel

/data2/Projects/Lei/HCP_VNav_comparision/scripts/Run_ICC_parallel.R

It reads the files from voxels generated from the step 2. It does this in batches (10000 voxels) and same one batch results into the txt file.


## 4. After running, using cat to concatenate all output files together. (this is very quick). For example:
rm /data2/Projects/Lei/HCP_VNav_comparision/ICC_New.txt; cat /data2/Projects/Lei/HCP_VNav_comparision/ICC_Value_new/{0..1153}.txt > /data2/Projects/Lei/HCP_VNav_comparision/ICC_New.txt


5. The the big aggregated 


 

