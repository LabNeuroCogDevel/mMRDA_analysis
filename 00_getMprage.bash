#!/usr/bin/env bash
# give me 
# 1) subjectid (lunaid_date)
# 2) the location of an mprage on meson
#
# will retrieve and process
#
# e.g
#  ./00_getMprage.bash 10672_20140318 '/disk/mace2/scan_data/DEV-LUNA/03.18.2014-12\:04\:49/B0026/*RAGE*'

scriptdir=$(cd $(dirname $0);pwd)

subjid=$1
[ -z "$subjid" ] && echo "first argument should be subjectid!" && exit 1;
mesonpath=$2
[ -z "$mesonpath" ] && echo "second argument should be path to RAGE on meson!" && exit 1;

# get mpragedir
. $scriptdir/settingsrc.bash

[ ! -d $mpragedir ] && mkdir -p $mpragedir
[ -z "$OVERWRITE" -a -r $mpragedir/mprage.nii.gz ] && echo "you already have an mprage! if you want to overwrite:
OVERWRITE=1 $0 $@" && exit 0

## GET
echo '$MRluna!899'
rsync -azvhi meson:$mesonpath/ $mpragedir/ 

## PROCESS
export FSLOUTPUTTYPE="NIFTI_GZ"
cd $mpragedir
preprocessMprage -r MNI_2mm -b "-R -f 0.5 -v" -d n -o mprage.nii.gz 
#-p "/data/Luna1/Raw/mMRDA-dev/10672_20140318/Functionals/Sagittal_MPRAGE_ADNI_256x240.7/MR*"

# add notes to mprage
for file in mprage.nii.gz mprage_warpcoef.nii.gz mprage_bet.nii.gz; do
  3dNotes -h "rsync -azvhi meson:$mesonpath/ $mpragedir/" $file
  3dNotes -h 'preprocessMprage -r MNI_2mm -b "-R -f 0.5 -v" -d n -o mprage.nii.gz' $file
done
