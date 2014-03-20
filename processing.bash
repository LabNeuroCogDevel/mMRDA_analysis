#!/usr/bin/env
## get from server
rsync -azvhi meson:/disk/mace2/scan_data/homeless/BRAIN^dev-luna2/03.18.2014-14:05:28/0026 ./
rsync -azvhi skynet:/Volumes/Serena/SPECC/MR_Raw/031814_PETMRI/ ./0026/Reconstructed/
rsync -azvhi meson:/disk/mace2/scan_data/DEV-LUNA/03.18.2014-12\:04\:49/B0026/  ./0026/Functionals/

### freesurf -- WRONG? -- should run FS on functions !!
##~/src/freesurfersearcher-general/surfOne.sh  -i 0026 -d /data/Luna1/Raw/mMRDA-dev/0026/axial_mprage_256x224.23/ -s  /data/Luna1/mMRDA-dev/FS_Subjects/
#subjectid=0026 niifile=/mMRDA-dev/mprage/0026/20140318_140528.nii.gz subjdir=/mMRDA-dev/FS_Subjects TYPE=mMRDA-dev /home/foranw/src/freesurfersearcher-genera
#l/queReconall.sh



# put script ahead of anything in ni_tools (use local preprocessfunctianal)
export PATH="/data/Luna1/mMRDA-dev/scripts/:$PATH"

## functaion mprage
mkdir -p /data/Luna1/mMRDA-dev/mprage/0026/{func,struct}
cd /data/Luna1/mMRDA-dev/mprage/0026/func/
preprocessMprage -r MNI_2mm -b "-R -f 0.5 -v" -d n -o 0026_20140318.nii.gz -p "/data/Luna1/Raw/mMRDA-dev/0026/Functionals/Sagittal_MPRAGE_ADNI_256x240.7/MR*"



## functional
funcdir=/data/Luna1/mMRDA-dev/functional/0026
mkdir $funcdir
cd 0026/Reconstructed/
export AFNI_ANALYZE_VIEW=orig AFNI_ANALYZE_ORIGINATOR=YES
for f in *hdr; do
 fb=$(basename $f .hdr)
 3dcopy $f $funcdir/$fb.nii.gz
done


## move funcs into their own directories
cd $funcdir
paste <(echo C1 C2 C3 C4 R1 R2 R3 R4 BART|tr ' ' '\n') \
      <(ls -1 --color=no *BOLD_x* | cut -d_ -f6 | cut -d. -f1|sort -u) | \
   while read dir run; do 
     mkdir $dir;
     mv *$run* $dir;
     echo $run > $dir/runid;
   done

mkdir Rest
mv *resting*nii.gz Rest

## preprocess functional:
# N.B. no field map correction! (TODO)
cd /data/Luna1/mMRDA-dev/functional/0026/C1
preprocessFunctional  -4d ep2d_MB_BOLD_x4_MB_8278.nii.gz  -mprage_bet /data/Luna1/mMRDA-dev/mprage/0026/func/mprage_bet.nii -warpcoef /data/Luna1/mMRDA-dev/mprage/0026/func/mprage_warpcoef.nii -4d_slice_motion -custom_slice_times  /data/Luna1/mMRDA-dev/scripts/mMRDA_MBTimings.1D  -tr 1.5 

## checkout slice timing
# from powerpoint:
#   MB acceleration factor=3
#   FOV/3 shift.  TR = 1500ms,TE = 30 ms, 45 slices (10.35 cm coverage), FOV = 220 mm, voxel size = 2.3 mm3, FA = 50 deg.
#
# cd /data/Luna1/Raw/mMRDA-dev/0026/Functionals/ep2d_MB_BOLD_x4_384x384.13
# #for f in *; do dicom_hdr -slice_times $f; done | cut -f2 -d:|tr ' ' '\n'|grep -v '^$' |sort |uniq -c
# for f in *; do dicom_hdr -slice_times $f; done | tee /data/Luna1/Raw/mMRDA-dev/stfor-epi13 |sort |uniq -c|sort
# order is 1 3 5 7 9 11 13 15 2 4 6 8 10 12 14
# e.g. 
#      26  0.0 802.5 100.0 905.0 202.5 1005.0 302.5 1105.0 402.5 1205.0 502.5 1305.0 602.5 1405.0 702.5
# aquired  1   9     2     10    3     11     4     12     5     13     6     14     7     15     8

# diff should be 100ms
