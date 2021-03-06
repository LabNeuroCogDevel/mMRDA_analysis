#!/usr/bin/env bash
#
# where are the folders
# how are subject ids suppose to look (lunaid_date)
# what should be in the path

[ -z "$subjid" ] && echo "need subject id!" && exit 1;

if [[ "$subjid" =~ [0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] ]]; then
  echo "$subjid should be lunaid_date"
  exit 1
fi

case $(hostname -s) in
 wallace)
   subjectroot="/data/Luna1/mMRDA-dev/subjects";;
 skynet)
   subjectroot="/Volumes/Serena/mMRDA-dev/subjects";;
esac


T1MNIref="MNI_2mm"
T2MNIref="MNI_3mm"
behavdir="$subjectroot/$subjid/behavior"
mpragedir="$subjectroot/$subjid/mprage/func/"
epidir="$subjectroot/$subjid/func"

analysisdir="$subjectroot/$subjid/analysis"

# make sure the files in the script directory take presidence over anything named the same in the path
# scriptdir should usually be defined before sourcing this script
[ -z "$scriptdir" ] && scriptdir=$(cd $(dirname $0);pwd)
export PATH="$scriptdir:$PATH"

# make sure we make .nii.gz with fsl
export FSLOUTPUTTYPE=NIFTI_GZ


function writelog {
  echo -e "### $(whoami) @ $(hostname -s) ⌚ $(date +"%F %H:%M") ###\n$@" >> $subjectroot/$subjid/make.log
}

function lognifti {
  nii=$1; shift;
  [ -z "$nii" -o ! -r "$nii" ] && echo "cannot log $nii, DNE" && return
  3dNotes $nii -h "[$(whoami)@$(hostname -s) $(date +"%F %H:%M")] $@" 
}
