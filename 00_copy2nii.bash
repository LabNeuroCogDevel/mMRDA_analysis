#!/usr/bin/env bash

# point me to a hdr/img (ANALYZE) directory
# and give me a new directory to put the niftis in
#
# e.g.
#
#  ./00_copy2nii.bash 1067_20140318 skynet:/Volumes/Serena/mMRDA-dev/MR_Raw/031814_PETMRI 
#  ./copyTonii.bash /Volumes/Serena/mMRDA-dev/MR_Raw/031814_PETMRI /Volumes/Serena/mMRDA-dev/subjects/10672_20140318
#  ./00_copy2nii.bash skynet:/Volumes/Serena/mMRDA-dev/MR_Raw/031814_PETMRI /data/Luna1/mMRDA-dev/subjects/1067_20140318

set -e

# what do the scan hdrs for look like (from Tae)
pattern='*BOLD_X[48]_MB*hdr'

subjid=$1
subjid=$1
[ -z "$subjid" ] && echo "first argument should be subjectid!" && exit 1;

hdrdir=$2
[ -z "$hdrdir" ] && echo "give me a path to the hdr/img files as first argument, maybe
  skynet:/Volumes/Serena/mMRDA-dev/MR_Raw/$subjid" && exit 1;

# later used for rsync if needed
tmpdir=

# get subjectroot 
scriptdir=$(cd $(dirname $0);pwd)
. $scriptdir/settingsrc.bash

savedir=$subjectroot/$subjid/
[ ! -d "$(dirname $savedir)" ] && echo "$(dirname $savedir) does not exist" && exit 1;


[ -z "$OVERWRITE" -a  $(ls $savedir/func/*/epi.nii.gz|wc -l) -ge 4 ] && echo "probably have what you want, skipping -- otherwise use
OVERWRITE=1 $0 $@" && exit 0


# remote location
if [[ $hdrdir =~ :[~/] ]]; then
 tmpdir=$savedir/hdrimg_Tae/
 mkdir -p $tmpdir
 rsync -avhi $hdrdir/ $tmpdir || exit 1
 hdrdir=$tmpdir
fi

[ ! -d "$hdrdir" ]  && echo "$hdrdir doesn't exist" && exit 1


# find all the epi images using the folder pattern
files="$(find $hdrdir -maxdepth 1 -iname $pattern | sort )"

nfiles=$(echo "$files"|wc -l|tr -d ' ' )

# what was the sequence of blocks (control1-reward4)
case  "$nfiles" in  
   "0") "no files matching $pattern" && exit 1;;
   "9") seq="C1 C2 C3 C4 R1 R2 R3 R4 BART";;
   "8") seq="C1 C2 C3 C4 R1 R2 R3 R4";;
   "4") seq="R1 R2 R3 R4";;
   *) echo "what should i do with $nfiles ($pattern)?" && exit 1;;
esac

export AFNI_ANALYZE_VIEW=orig AFNI_ANALYZE_ORIGINATOR=YES
# create mesh based on files
paste <(echo "$seq"|tr ' ' '\n') <(echo "$files")|while read block file; do
 filename=$savedir/func/$block/epi.nii.gz 
 thissavedir=$(dirname $filename)
 [ -r $filename ] && continue # already did this
 mkdir -p $thissavedir # make dir if not already there
 3dcopy $file $filename
 3drefit -TR 1.5 $filename
 echo "$file -> $block $(date +%F)" > $savedir/func/$block/log
done
echo -e "### $(whoami) @ $(hostname -s) $(date +"%F %H:%M") ###\n$0 $@ " >> $savedir/make.log

# cleanup
# [ ! -z "$tmpdir" ] && rm -r $tmpdir
