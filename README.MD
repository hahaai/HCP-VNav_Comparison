# HCP and VNav Comparison.

Generate data directory is:
/data2/Projects/Lei/HCP_VNav_comparision/scripts/README.txt


1. Data organization and registion.
/data2/Projects/Lei/HCP_VNav_comparision/scripts/HCP_VNav_comp.sh
 a. It extract HCP and VNav images from CBIC.
 b. IT also runs FSL SIENA on each subject.
 C. Register HCP to VNav and VNav to HCP
 d. Retister them to MNI space???


2. Using Python scripts to read in each image and then convert to ICC run ready data structure and save date for each voxel.

/data2/Projects/Lei/HCP_VNav_comparision/scripts/ICC_Prep.py

It can save both HCP2VNav and VNav2HCP into different folders.

3. Run ICC on each voxel in R in parallel

/data2/Projects/Lei/HCP_VNav_comparision/scripts/Run_ICC_parallel.R

It reads the files from voxels generated from the step 2. It does this in batches (10000 voxels) and same one batch results into the txt file.


4. After running, using cat to concatenate all output files together. (this is very quick). For example:
rm /data2/Projects/Lei/HCP_VNav_comparision/ICC_New.txt; cat /data2/Projects/Lei/HCP_VNav_comparision/ICC_Value_new/{0..1153}.txt > /data2/Projects/Lei/HCP_VNav_comparision/ICC_New.txt


5. The the big aggregated 


 

