#!/usr/bin/env bash
# given subject and matfile, produce stimfiles in subject/behav/stimfiles/0x_xxxx.1D
#

subjid=$1
[ -z "$subjid" ] && echo "first argument should be subjectid!" && exit 1;

matpath=$2
[ -z "$matpath" ] && echo "second argument should be path to mat file (server:/path or /path)!" && exit 1;


# get behavdir
scriptdir=$(cd $(dirname $0);pwd)
. $scriptdir/settingsrc.bash

# bail if we've already done this
[ -z "$OVERWRITE" -a -d $behavdir/stimtimes ] && echo "you appear to already have stimfiles! if you want to redo:
OVERWRITE=1 $0 $@" && exit 0

[ ! -d "$behavdir" ] && mkdir -p $behavdir


# get file
set -xe
rsync -azvhi $matpath $behavdir/

matfile="$(find $behavdir/$(basename $matpath) -type f| sed 1q)"
[ -z "$matfile" -o ! -r "$matfile" ] && echo "Cannot find/read '$matfile'" && exit 1
## run matlab to generate stim files
echo $matfile
cd $scriptdir
matlab -nodisplay -r "try, genStimTimes('$matfile'), catch, fprintf('***********\ncould not write stim files!\n'), end; quit; "

[ ! -d stimtimes/$subjid ] && echo "failed to create stimfiles" && exit 1

[ -d $behavdir/stimtimes ] && mv $behavdir/stimtimes $behavdir/$(date +%F:%H:%M)_stimtimes_old
mv stimtimes/$subjid $behavdir/stimtimes

#echo "$0 $@ #[$(hostname -s)] $(date +"%F %H:%M") " >> $subjectroot/info.log
writelog "$0 $@"

