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


[ ! -d "$behavdir" ] && mkdir -p $behavdir

# get file
rsync -azvhi $matpath $behavdir/

matfile=$behavdir/$(basename $matpath)
[ ! -r $matfile ] && echo "Cannot find/read '$matfile'" && exit 1

## run matlab to generate stim files
cd $scriptdir
matlab -nodesktop -r "
try,
  genStimTimes('$matfile');
catch,
  fprintf('***********\ncould not write stim files!\n');
end;
quit;
"

