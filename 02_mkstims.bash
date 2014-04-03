#!/usr/bin/env bash

# which stim times runs (1-8) wich blocks (R1-3)
#
# run from 02_deconvolveall.bash

#  or inside an analysis directory
# 02_mkstims.bash subject_date 5678 1234

subjid=$1
[ -z "$subjid"  ] && echo "need a subject id!" && exit 1
shift

# get 
#   behavdir="$subjectroot/$subjid/behavior"
#   epidir="$subjectroot/$subjid/func"
scriptdir=$(cd $(dirname $0);pwd)
. $scriptdir/settingsrc.bash


# should be run in analysis directory
[ "$(pwd)" != $analysisdir ] && echo "$0 should be run from $analysisdir not $(pwd)" && exit 1


# get run(5678) and reward block (1234)
runs=$1
rewards=$2
[ -z "$runs" ] && echo "need runs like 5678 as second argument" && exit 1
[ -z "$rewards" ] && echo "need reward blocks corresponding to runs like 1234 as third argument" && exit 1

stimdir="$behavdir/stimtimes/"
savedir=stims/
[ ! -d "$savedir" ] && mkdir -p "$savedir"

for stim in WIN NOWIN response spin start spin:duration start:duration allresults; do
  for f in $stimdir/0[$runs]_$stim.1D; do 
    [ ! -r $f ] && echo "missing stim: $f" 1>&2 && exit 1
    cat $f;
    echo; # need a new line
  done > $savedir/$runs$stim.1D
done

cat $epidir/R[$rewards]/3dvolreg.par > $savedir/${runs}motion.par
cat $epidir/R[$rewards]/mcplots.par  > $savedir/${runs}mcplots.par
