#!/usr/bin/env bash
#
# outline for running deconvolve
# input:
#   functional 
#   block number (1-8, to find stimfile)
#
# output:
#  ????
#
# stim files are generated from mat output and genStimTimes.m
# curerntly saved in ../behav/0026/SlotStims/
scriptdir=$(cd $(dirname $0);pwd)
stimdir=$scriptdir/../behav/10672_20140318/SlotStims/


# check functional input
func=$1
[ -z "$func" -o ! -r "$func" ] && echo "Cannot read '$func'" && exit 1

# check stim input
blk=$(printf '%02d' $2)
for s in NOWIN WIN;do
 stimfile=$(find $stimdir -name ${blk}_$s\*.1D | sed 1q)
 [ -z "$stimfile" -o ! -r $stimfile ] && echo "cannot find '$stimfile'" && exit 1
 printf -v "stim${s}" $stimfile
done

stimstart=$scriptdir/../behav/10672_20140318/SlotStims/${blk}_duration_start.1D
stimspin=$scriptdir/../behav/10672_20140318/SlotStims/${blk}_duration_spin.1D

#nTR=$(3dinfo -nv $func)
#TR=1.5

echo "$func($nTR) $blk $stimNOWIN"

3dDeconvolve                                           \
      -input $func \
      -polort 9     -tout                              \
      -num_stimts 4                                    \
      -stim_times_AM1 1 $stimstart 'dmBLOCK(1)' \
      -stim_label 1 slotstart                               \
      -stim_times_AM1 2 $stimspin 'dmBLOCK(1)' \
      -stim_label     2 anticipation                       \
      -stim_times 3 $stimWIN 'BLOCK(1,1)'    \
      -stim_label 3 win                                \
      -stim_times 4 $stimNOWIN 'BLOCK(1,1)' \
      -stim_label 4 nowin                            \
      -num_glt 4                                     \
      -gltsym "SYM: win  -nowin"              -glt_label 1 wVn  \
      -gltsym "SYM: anticipation -win"        -glt_label 2 aVw  \
      -gltsym "SYM: anticipation -nowin"      -glt_label 3 aVn  \
      -gltsym "SYM: anticipation -nowin -win" -glt_label 4 aVwn \
      -bucket intialcontrasts.nii.gz

      #-x1D stims/${ii}_X.xmat.1D   >  stims/${ii}.3ddlog 2>&1

      #-stim_times 1 stims/${ii}_stimes_spin.1D 'GAM' \
      #-stim_label 1 spin                               \
      #-stim_times 2 stims/${ii}_stimes_*_win.1D 'BLOCK(1.5,1)'     \
      # -stim_times 3 stims/${ii}_stimes_*nowin 'BLOCK(1.5,1)'    \

