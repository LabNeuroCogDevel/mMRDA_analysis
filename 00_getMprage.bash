#!/usr/bin/env bash
# give me 
# 1) subjectid (lunaid_date)
# 2) the location of an mprage dicom directory
#
# will retrieve and process
#
# e.g
#  ./00_getMprage.bash 10672_20140318 'meson:/disk/mace2/scan_data/DEV-LUNA/03.18.2014-12\:04\:49/B0026/*RAGE*'
#  ./00_getMprage.bash 10811_20140321 'meson:/disk/mace2/scan_data/homeless/BRAIN^dev-luna1/03.21.2014-15:04:20/10811_20140321/axial_mprage_256x224.12'


scriptdir=$(cd $(dirname $0);pwd)

subjid=$1
[ -z "$subjid" ] && echo "first argument should be subjectid!" && exit 1;
remotepath=$2
[ -z "$remotepath" ] && echo "second argument should be path to RAGE on meson!" && exit 1;

# get mpragedir and T1MNIref (MNI_2mm)
. $scriptdir/settingsrc.bash

[ ! -d $mpragedir ] && mkdir -p $mpragedir
[ -z "$OVERWRITE" -a -r $mpragedir/mprage.nii.gz ] && echo "you already have an mprage! if you want to overwrite:
OVERWRITE=1 $0 $@" && exit 0

# actual command all of this boils down to
cmd="preprocessMprage -r $T1MNIref -b \"-R -f 0.5 -v\" -d n -o mprage_nonlinear_warp_$T1MNIref.nii.gz "
#-p "/data/Luna1/Raw/mMRDA-dev/10672_20140318/Functionals/Sagittal_MPRAGE_ADNI_256x240.7/MR*"

echo '$MRluna!899'
set -xe
## GET
rsync -azvhi $remotepath/ $mpragedir/ 

## PROCESS
cd $mpragedir
eval $cmd

# add notes to mprage
for file in mprage.nii.gz mprage_warpcoef.nii.gz mprage_bet.nii.gz; do
  lognifti "rsync -azvhi $remotepath/ $mpragedir/" $file
  lognifti "$cmd" $file
done

writelog " ## $0 $@\n$cmd"
