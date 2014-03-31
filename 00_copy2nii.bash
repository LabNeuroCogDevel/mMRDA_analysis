#!/usr/bin/env bash

# point me to a hdr/img (ANALYZE) directory
# and give me a new directory to put the niftis in
#
# e.g.
#
#  ./copyTonii.bash /Volumes/Serena/mMRDA-dev/MR_Raw/031814_PETMRI /Volumes/Serena/mMRDA-dev/subjects/10672_20140318
#  ./00_copy2nii.bash skynet:/Volumes/Serena/mMRDA-dev/MR_Raw/031814_PETMRI /data/Luna1/mMRDA-dev/subjects/1067_20140318

set -e


hdrdir=$1
[ -z "$hdrdir" ] && echo "give me a path to the hdr/img files as first argument" && exit 1;
# later used for rsync if needed
tmpdir=

savedir=$2
[ -z "$savedir" ] && echo "second argument should be a folder to save to" && exit 1;
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


# find all the epi images
pattern='*BOLD_X4_MB*hdr'
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
 [ -r $savedir/func/$block/epi.nii.gz ] && continue
 mkdir -p $savedir/func/$block
 3dcopy $file $savedir/func/$block/epi.nii.gz
 echo "$file -> $block $(date +%F)" > $savedir/func/$block/log
done
echo "$0 $@ #[$(hostname -s) $(date +"%F %H:%M")" >> $savedir/make.log

# cleanup
# [ ! -z "$tmpdir" ] && rm -r $tmpdir
