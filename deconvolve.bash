#!/usr/bin/env bash
#
# outline for running deconvolve
# input:
#   1) functional 
#   2) block number (1-8, to find stimfile)
#   3) mcplots.par
#
# output:
#  ????
#
# stim files are generated from mat output and genStimTimes.m
# curerntly saved in ../behav/0026/SlotStims/
scriptdir=$(cd $(dirname $0);pwd)

# set stim dir if we haven't
[ -z "$stimdir" ] && stimdir=$scriptdir/../behav/10672_20140318/SlotStims/


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

stimstart=$stimdir/${blk}_duration_start.1D
 stimspin=$stimdir/${blk}_duration_spin.1D

# use mcplots ot make mcplots_censor.1D
mcpar=$3
[ -z "$3" -o ! -r "$3" ] && echo "cannot read motion '$mcpar'" && exit 1
1d_tool.py -infile $mcpar -show_censor_count -censor_prev_TR -censor_motion 1 mcplots

mcpardir=$(cd $(dirname $mcpar);pwd)
motion1D="$mcpardir/3dvolreg.par" # output from 3dvolreg from MH's preprocessFunctional
[ ! -r "$motion1D" ] && echo "cannot read motion censor file '$motion1D'" && exit 1

#nTR=$(3dinfo -nv $func)
#TR=1.5

echo "$func($nTR) $blk"
echo -e "start\t$stimstart\nanti\t$stimspin\nwin\t$stimWIN\nnowin\t$stimNOWIN"

3dDeconvolve                                           \
      -input $func \
      -polort 3     -tout                              \
      -overwrite                                       \
      -num_stimts 10                                    \
      -stim_file 1 $motion1D'[0]' -stim_base 1 -stim_label 1 rx   \
      -stim_file 2 $motion1D'[1]' -stim_base 2 -stim_label 2 ry   \
      -stim_file 3 $motion1D'[2]' -stim_base 3 -stim_label 3 rz   \
      -stim_file 4 $motion1D'[3]' -stim_base 4 -stim_label 4 mx   \
      -stim_file 5 $motion1D'[4]' -stim_base 5 -stim_label 5 my   \
      -stim_file 6 $motion1D'[5]' -stim_base 6 -stim_label 6 mz   \
      \
      -stim_times_AM1 7 $stimstart 'dmBLOCK(1)' \
      -stim_label 7 slotstart                               \
      -stim_times_AM1 8 $stimspin 'dmBLOCK(1)' \
      -stim_label     8 anticipation                       \
      -stim_times 9 $stimWIN 'BLOCK(1,1)'    \
      -stim_label 9 win                                \
      -stim_times 10 $stimNOWIN 'BLOCK(1,1)' \
      -stim_label 10 nowin                            \
      \
      -num_glt 8                                     \
      -censor  mcplots_censor.1D                     \
      -gltsym "SYM: win  +nowin"              -glt_label 1 outcome  \
      -gltsym "SYM: win  -nowin"              -glt_label 2 win-nowin  \
      -gltsym "SYM: win"                      -glt_label 3 win  \
      -gltsym "SYM: nowin"                    -glt_label 4 nowin  \
      -gltsym "SYM: anticipation"             -glt_label 5 anticipation  \
      -gltsym "SYM: anticipation -win"        -glt_label 6 anti-win  \
      -gltsym "SYM: anticipation -nowin"      -glt_label 7 anti-nowin  \
      -gltsym "SYM: anticipation -nowin -win" -glt_label 8 anti-outcome \
      -bucket intialcontrasts.nii.gz

      #-x1D stims/${ii}_X.xmat.1D   >  stims/${ii}.3ddlog 2>&1

      #-stim_times 1 stims/${ii}_stimes_spin.1D 'GAM' \
      #-stim_label 1 spin                               \
      #-stim_times 2 stims/${ii}_stimes_*_win.1D 'BLOCK(1.5,1)'     \
      # -stim_times 3 stims/${ii}_stimes_*nowin 'BLOCK(1.5,1)'    \

1d_tool.py -cormat_cutoff 0 -show_cormat_warnings -infile intialcontrasts.xmat.1D | tee initialcontrasts.colin.txt
