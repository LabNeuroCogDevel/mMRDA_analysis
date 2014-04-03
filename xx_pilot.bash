#!/usr/bin/env bash
# this is how we'd get the pilot data

# pilot has luna id 10672 and date 20140318
# -- also grab 2 others 

set -xe

subjid=10672_20140318

# get mprage from meson (should have meson defined in .ssh/config, will have to give password)
# also warp to standard space
#./00_getMprage.bash $subjid 'meson:/disk/mace2/scan_data/DEV-LUNA/03.18.2014-12\:04\:49/B0026/*RAGE*'

# get the hdr/img files from Tae and convert to nii.gz 
#./00_copy2nii.bash $subjid skynet:/Volumes/Serena/mMRDA-dev/MR_Raw/031814_PETMRI

# get the matfile and translate it into stimtimes
#./00_getBehav.bash $subjid reese:/home/foranw/src/SlotTask/data/$subjid/SlotPETMRI\*.mat

# run standard preprocessing on the epi
# for kids, we dont want to do the C (control) block
for blk in {C,R}{1..4}; do
 ./01_preprocess.bash $subjid $blk
done

./02_deconvolveall.bash $subjid 67 23
./02_deconvolveall.bash $subjid 5678 1234

## ---- ### 
# fMRI only
subjid=10811_20140321
#./00_getBehav.bash $subjid reese:~/src/SlotTask/data/10811_20140321/SlotPETMRI_10811_20140321.mat
#./00_copy2nii.bash $subjid skynet:/Volumes/Serena/mMRDA-dev/MR_Raw/$subjid
#./00_getMprage.bash $subjid meson:/disk/mace2/scan_data/homeless/BRAIN^dev-luna1/03.21.2014-15:04:20/10811_20140321/axial_mprage_256x224.12

#for blk in R{1..4}; do
for blk in R{3..4}; do
 ./01_preprocess.bash $subjid $blk
done

./02_deconvolveall.bash $subjid 1234 1234


## ---- ### 
#./00_copy2nii.bash  11276_20140331 skynet:/Volumes/Serena/mMRDA-dev/MR_Raw/11276_20140331 
#./00_getMprage.bash 11276_20140331 meson:/disk/mace2/scan_data/homeless/BRAIN^dev-luna2/03.31.2014-12:01:38/B0030/axial_mprage_256x224.32
#./00_getBehav.bash  11276_20140331 foranw@reese:/mnt/B/bea_res/PET-fMRI/DataforWill/11276_20140331/SlotPETMRI_11276_20140331.mat
for blk in R{1..4}; do
 ./01_preprocess.bash $subjid $blk
done

./02_deconvolveall.bash $subjid 67 23
./02_deconvolveall.bash $subjid 5678 1234
