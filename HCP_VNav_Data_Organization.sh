#

### Data Organization
datain='/data2/HBNcore/CMI_HBN_Data/MRI/CBIC/data'

dataout='/data2/Projects/Lei/HCP_VNav_comparision/data'

for sub in $(ls $datain);do
    echo $sub
    hcp=$datain'/'$sub'/anat/'$sub'_acq-HCP_T1w.nii.gz'
    vnav=$datain'/'$sub'/anat/'$sub'_acq-VNav_T1w.nii.gz'
    if [[ -f $hcp ]] && [[ -f $vnav ]];then
        mkdir -p $dataout'/'$sub
        ln -s $hcp $dataout'/'$sub'/HCP.nii.gz'
        ln -s $vnav $dataout'/'$sub'/VNav.nii.gz'
    fi
done



### Run fsl siena on all subjects. need to run in parallel
siena_command='/data2/Projects/Lei/HCP_VNav_comparision/scripts/siena_commands.txt'
rm $siena_command
datain='/data2/Projects/Lei/HCP_VNav_comparision/data'
for sub in $(ls $datain);do
    echo 'siena '$datain'/'$sub'/HCP.nii.gz' $datain'/'$sub'/VNav.nii.gz -o '$datain'/'$sub'/siena_output' >> $siena_command
done





### register HCP to VNav using flirt with dof at 6
reg_command='/data2/Projects/Lei/HCP_VNav_comparision/scripts/reg_commands.txt'
rm $reg_command

datain='/data2/Projects/Lei/HCP_VNav_comparision/data'

# 3dAllineate -base VNav.nii.gz -input HCP.nii.gz -prefix HCP2VNav_test.nii.gz -interp quintic -warp shr
for sub in $(ls $datain);do
    echo '3dAllineate -input '$datain'/'$sub'/HCP.nii.gz -base '$datain'/'$sub'/VNav.nii.gz -prefix '$datain'/'$sub'/HCP2VNav.nii.gz -interp quintic -warp shr' >> $reg_command
    echo '3dAllineate -input '$datain'/'$sub'/VNav.nii.gz -base '$datain'/'$sub'/HCP.nii.gz -prefix '$datain'/'$sub'/VNav2HCP.nii.gz -interp quintic -warp shr' >> $reg_command
done


################3 registrer both image to MNI Space

### Run fsl siena with -m (standard option) on all subjects. need to run in parallel
# This will generat teh A2std and B2std mat, then apply those mats to the original imge with skull (head)
siena_command='/data2/Projects/Lei/HCP_VNav_comparision/scripts/siena_std_commands.txt'
rm $siena_command
datain='/data2/Projects/Lei/HCP_VNav_comparision/data'
for sub in $(ls $datain);do
    echo 'siena '$datain'/'$sub'/HCP.nii.gz' $datain'/'$sub'/VNav.nii.gz -o '$datain'/'$sub'/siena_output_standard -m' >> $siena_command
done

# register to MNI 2 mm usign the transformation.
reg_command='/data2/Projects/Lei/HCP_VNav_comparision/scripts/reg_std_commands.txt'
rm $reg_command

datain='/data2/Projects/Lei/HCP_VNav_comparision/data'

# 3dAllineate -base VNav.nii.gz -input HCP.nii.gz -prefix HCP2VNav_test.nii.gz -interp quintic -warp shr
for sub in $(ls $datain);do
    echo $sub
    HCP=$datain'/'$sub'/HCP.nii.gz'
    HCP2std_mat=$datain'/'$sub'/siena_output_standard/A_to_std.mat'
    HCPout=$datain'/'$sub'/HCP2std.nii.gz'

    VNav=$datain'/'$sub'/VNav.nii.gz'
    VNav2std_mat=$datain'/'$sub'/siena_output_standard/B_to_std.mat'
    VNavout=$datain'/'$sub'/VNav2std.nii.gz'

    echo "flirt -in "$HCP" -ref /usr/share/fsl/data/standard/MNI152_T1_2mm.nii.gz -init "$HCP2std_mat" -o "$HCPout" -applyxfm" >> $reg_command
    echo "flirt -in "$VNav" -ref /usr/share/fsl/data/standard/MNI152_T1_2mm.nii.gz -init "$VNav2std_mat" -o "$VNavout" -applyxfm" >> $reg_command
done



########## running pve on images in subject space. Also run flirt and fnirt registration.
datain='/data2/Projects/Lei/HCP_VNav_comparision/data'

brain_extraction_commnad='/data2/Projects/Lei/HCP_VNav_comparision/scripts/brain_extraction_commands.txt'
rm $brain_extraction_commnad

pve_commnad='/data2/Projects/Lei/HCP_VNav_comparision/scripts/pve_commands.txt'
rm $pve_commnad

flirt_fnirt_commnad='/data2/Projects/Lei/HCP_VNav_comparision/scripts/flirt_fnirt_commands.txt'
rm $flirt_fnirt_commnad

for sub in $(ls $datain);do
    echo $sub
    HCP=$datain'/'$sub'/HCP.nii.gz'
    VNav=$datain'/'$sub'/VNav.nii.gz'
    outdir=$datain'/'$sub'/std_pve' 
    mkdir $outdir

    # brain extrating using 3dskullstrip on two images first. bet does not give good resutls. This must be done befor the other two steps
    # also do nu correciotn and N4 normalization
    # mri_nu_correct.mni --i $anat_brain --o brain_nu.nii.gz  --n 6 --proto-iters 150 --stop .0001;
    # N4BiasFieldCorrection -d 3 -i brain_nu.nii.gz -o brain_nuN4.nii.gz;

    if [[ ! -f $outdir'/HCP_brain.nii.gz' ]] | [[ ! -f $outdir'/VNav_brain.nii.gz' ]];then
        echo "mri_nu_correct.mni --i $HCP --o $outdir/HCP_nu.nii.gz --n 6 --proto-iters 150 --stop .0001; N4BiasFieldCorrection -d 3 -i $outdir/HCP_nu.nii.gz -o $outdir/HCP_nuN4.nii.gz; 3dSkullStrip -input $outdir/HCP_nuN4.nii.gz -prefix $outdir/HCP_brain_nuN4.nii.gz -orig_vol;"  >> $brain_extraction_commnad

        echo "mri_nu_correct.mni --i $VNav --o $outdir/VNav_nu.nii.gz --n 6 --proto-iters 150 --stop .0001; N4BiasFieldCorrection -d 3 -i $outdir/VNav_nu.nii.gz -o $outdir/VNav_nuN4.nii.gz; 3dSkullStrip -input $outdir/VNav_nuN4.nii.gz -prefix $outdir/VNav_brain_nuN4.nii.gz -orig_vol;"  >> $brain_extraction_commnad

    fi
    

    HCP_brain=$outdir'/HCP_brain_nuN4.nii.gz'
    VNav_brain=$outdir'/VNav_brain_nuN4.nii.gz'


    HCP_head=$outdir'/HCP_nuN4.nii.gz'
    VNav_head=$outdir'/VNav_nuN4.nii.gz'


    # flirt and fnirt
    echo "flirt -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -in $HCP_brain -omat $outdir/HCP2std_flirt.mat; fnirt --in=$HCP_head --aff=$outdir/HCP2std_flirt.mat --cout=$outdir/HCP2std_nonlinear_transf --config=T1_2_MNI152_2mm; applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain --in=$HCP_brain --warp=$outdir/HCP2std_nonlinear_transf --out=$outdir/HCP2std.nii.gz" >> $flirt_fnirt_commnad

    
    echo "flirt -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -in $VNav_brain -omat $outdir/VNav2std_flirt.mat; fnirt --in=$VNav_head --aff=$outdir/VNav2std_flirt.mat --cout=$outdir/VNav2std_nonlinear_transf --config=T1_2_MNI152_2mm; applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain --in=$VNav_brain --warp=$outdir/VNav2std_nonlinear_transf --out=$outdir/VNav2std.nii.gz" >> $flirt_fnirt_commnad
    #echo "fnirt --in=$VNav --aff=$outdir/VNav2std_flirt.mat --cout=$outdir/VNav2std_nonlinear_transf --config=T1_2_MNI152_2mm; applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=$VNav_brain --warp=$outdir/VNav2std_nonlinear_transf --out=$outdir/VNav2std.nii.gz" >> $flirt_fnirt_commnad

    # FAST on 
    echo "fast $HCP_brain" >> $pve_commnad
    echo "fast $VNav_brain" >> $pve_commnad
 
done


### apply the warp file to PVE1.
#applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=$VNav_brain --warp=$outdir/VNav2std_nonlinear_transf --out=$outdir/VNav2std.nii.gz"
#/data2/Projects/Lei/HCP_VNav_comparision/data/sub-5007372/std_pve/HCP_brain_nuN4_pve_0.nii.gz
# /data2/Projects/Lei/HCP_VNav_comparision/data/sub-5007372/std_pve/HCP2std_nonlinear_transf.nii.gz

datain='/data2/Projects/Lei/HCP_VNav_comparision/data'
pve_to_std='/data2/Projects/Lei/HCP_VNav_comparision/scripts/pve2std_commands.txt'
rm $pve_to_std

for sub in $(ls $datain);do
    for type in HCP VNav;do 
        warp=$datain'/'$sub'/std_pve/'$type'2std_nonlinear_transf.nii.gz'
        for pvenum in 0 1 2;do
            pve=$datain'/'$sub'/std_pve/'$type'_brain_nuN4_pve_'$pvenum'.nii.gz'
            echo "applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=$pve --warp=$warp --out=${pve/.nii.gz/_std.nii.gz}" >> $pve_to_std
        done
    done
done


### 
 #bet my_structural my_betted_structural
 #flirt -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -in my_betted_structural -omat my_affine_transf.mat
 #fnirt --in=my_structural --aff=my_affine_transf.mat --cout=my_nonlinear_transf --config=T1_2_MNI152_2mm
 #applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=my_structural --warp=my_nonlinear_transf --out=my_warped_structural




##### doing ANTs registration, save warp file and transformation.
#Sample running:
# /data2/Projects/Lei/HCP_VNav_comparision/scripts/ants_registration.sh /usr/share/fsl/data/standard/MNI152_T1_2mm.nii.gz /data2/Projects/Lei/HCP_VNav_comparision/scripts/ANTs_test/HCP.nii.gz forproduction
# The ants sample scripts needs to be in the directory where to save to outfiles, otherwise, it will just save in the current directory.

datain='/data2/Projects/Lei/HCP_VNav_comparision/data'
ANTs_commnad='/data2/Projects/Lei/HCP_VNav_comparision/scripts/anats_commands.txt'
rm $ANTs_commnad

for sub in $(ls $datain);do
    echo $sub
    HCP=$datain'/'$sub'/HCP.nii.gz'
    VNav=$datain'/'$sub'/VNav.nii.gz'
    outdir=$datain'/'$sub'/ANTs_std' 
    mkdir $outdir
    echo "cd $outdir; /data2/Projects/Lei/HCP_VNav_comparision/scripts/ants_registration.sh /usr/share/fsl/data/standard/MNI152_T1_2mm.nii.gz $HCP forproduction" >> $ANTs_commnad
    echo "cd $outdir; /data2/Projects/Lei/HCP_VNav_comparision/scripts/ants_registration.sh /usr/share/fsl/data/standard/MNI152_T1_2mm.nii.gz $VNav forproduction" >> $ANTs_commnad
done

cat /data2/Projects/Lei/HCP_VNav_comparision/scripts/anats_commands.txt | wc -l 15






