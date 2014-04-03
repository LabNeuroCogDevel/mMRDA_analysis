#!/usr/bin/env bash

set -xe
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
subjid=$1
[ -z "$subjid"  ] && echo "need a subject id!" && exit 1
shift



runs=$1
rewards=$2
# [$runs] which reward runs to use
[ -z "$runs"  ] && runs=1234
# the stim blocks that corrispond to those runs
[ -z "$rewards" ] && rewards=$runs

# get 
scriptdir=$(cd $(dirname $0);pwd)
. $scriptdir/settingsrc.bash


[ -d "$analysisdir" ] || mkdir -p "$analysisdir"
cd $analysisdir
# this is sketchy -- the stimtimes are dumpted into whatever folder we run from
$scriptdir/02_mkstims.bash $subjid $runs $rewards
stimsdir="stims/"



# stim files are generated from mat output and genStimTimes.m
# curerntly saved in ../behav/0026/SlotStims/
outputname=${subjid}_SpnCon_motreg_norest_$rewards


# for anticipation (dmBlock for ISI)
stimstart=$stimsdir/${runs}start.1D
stimstartdur=$stimsdir/${runs}start:duration.1D
stimspin=$stimsdir/${runs}spin:duration.1D
stimWIN="$stimsdir/${runs}WIN.1D"
stimNOWIN="$stimsdir/${runs}NOWIN.1D"

# for RT (dmBlock only on ISI onset -- response)
stimRT=$stimsdir/${runs}response.1D
stimRes="$stimsdir/${runs}allresults.1D"

# use mcplots ot make mcplots_censor.1D
mcpar=$stimsdir/${runs}mcplots.par
1d_tool.py -overwrite -infile $mcpar -show_censor_count -censor_prev_TR -censor_motion 1 $stimsdir/${runs}mcplots

motion1D="$stimsdir/${runs}motion.par" # output from 3dvolreg from MH's preprocessFunctional
[ ! -r "$motion1D" ] && echo "cannot read motion censor file '$motion1D'" && exit 1

#nTR=$(3dinfo -nv $func)
#TR=1.5


## task ends before recording ends
# -- task ends ~12 seconds after last reciept
# output is like:
#   R1/nfswkm_10811_20140321_epi.nii.gz'[0..191]'
#   R2/nfswkm_epi_R2_10811_20140321.nii.gz'[0..191]'
#   R3/nfswkm_epi_R3_10811_20140321.nii.gz'[0..188]'
#   R4/nfswkm_epi_R4_10811_20140321.nii.gz'[0..187]'
# -- always take the min between 12secs after last result and total volumes

inputs=$( 
	paste <(paste <(ls $epidir/R[$rewards]/n*epi*.nii.gz)  \
	        <(3dinfo -nv $epidir/R[$rewards]/n*epi*.nii.gz)
          ) $stimRes |
	perl -slane '$a=($F[$#F]+12)/1.5;print sprintf("%s[0..%.0f]",$F[0], ($F[1]<$a ? $F[1] : $a) -1)'
)

# we could stop this by specifing a 4th argument
if [ -z "$4"] ;then
 3dDeconvolve                                           \
      -input  \
          $inputs                                      \
      -polort 3     -tout                              \
      -overwrite                                       \
      -num_stimts 10                                    \
      -stim_file 1 $motion1D'[0]' -stim_base 1 -stim_label 1 rx   \
      -stim_file 2 $motion1D'[1]' -stim_base 2 -stim_label 2 ry   \
      -stim_file 3 $motion1D'[2]' -stim_base 3 -stim_label 3 rz   \
      -stim_file 4 $motion1D'[3]' -stim_base 4 -stim_label 4 mx   \
      -stim_file 5 $motion1D'[4]' -stim_base 5 -stim_label 5 my   \
      -stim_file 6 $motion1D'[5]' -stim_base 6 -stim_label 6 mz   \
      -stim_times_AM1 7 $stimstartdur 'dmBLOCK(1)' \
      -stim_label 7 slotstart                               \
      -stim_times_AM1 8 $stimspin 'dmBLOCK(1)' \
      -stim_label 8 RT                       \
      -stim_times 9 $stimWIN 'BLOCK(1,1)'    \
      -stim_label 9 win                                \
      -stim_times 10 $stimNOWIN 'BLOCK(1,1)' \
      -stim_label 10 nowin                            \
      \
      -num_glt 5                                     \
      -censor $stimsdir/${runs}mcplots_censor.1D            \
      -gltsym "SYM: win  +nowin"    -glt_label 1 feedback  \
      -gltsym "SYM: win  -nowin"    -glt_label 2 win-nowin  \
      -gltsym "SYM: RT -win"        -glt_label 3 RT-win  \
      -gltsym "SYM: RT -nowin"      -glt_label 4 RT-nowin  \
      -gltsym "SYM: RT -nowin -win" -glt_label 5 RT-outcome \
      -bucket $outputname.nii.gz

      #\
      #-stim_times_AM1 7 $stimstartdur 'dmBLOCK(1)' \
      #-stim_label 7 slotstart                               \
      #-stim_times 8 $stimRT 'GAM' \
      #-stim_label 8 RT                       \
      #-stim_times 9 $stimWIN 'BLOCK(1,1)'    \
      #-stim_label 9 win                                \
      #-stim_times 10 $stimNOWIN 'BLOCK(1,1)' \
      #-stim_label 10 nowin                            \

      #-x1D stims/${ii}_X.xmat.1D   >  stims/${ii}.3ddlog 2>&1

      #-stim_times 1 stims/${ii}_stimes_spin.1D 'GAM' \
      #-stim_label 1 spin                               \
      #-stim_times 2 stims/${ii}_stimes_*_win.1D 'BLOCK(1.5,1)'     \
      # -stim_times 3 stims/${ii}_stimes_*nowin 'BLOCK(1.5,1)'    \

 1d_tool.py -cormat_cutoff 0 -show_cormat_warnings -infile $outputname.xmat.1D | tee $outputname.co-lin.txt

 #./takepic.bash $outputname.nii.gz

 writelog "$0 $@\n#3dNotes $(pwd)/$outputname.nii.gz"
fi

##### also do RT only
# run a very simple regerssion if ask for (4th actual argument, 3rd after subject)
if [ -n "$3" ]; then
 outputname=${subjid}_RTCon_norest_$rewards
 3dDeconvolve                                           \
      -input  \
          $inputs                    \
      -polort 3     -tout                              \
      -overwrite                                       \
      -num_stimts 3                                    \
      \
      -stim_times 1 $stimstart 'BLOCK(1,1)' \
      -stim_label 1 slotstart                               \
      -stim_times 2 $stimRT 'GAM' \
      -stim_label 2 RT                       \
      -stim_times 3 $stimRes 'BLOCK(1,1)'    \
      -stim_label 3 feedback                                \
      -censor  stims/${runs}mcplots_censor.1D                     \
      -bucket $outputname.nii.gz \

 1d_tool.py -cormat_cutoff 0 -show_cormat_warnings -infile $outputname.xmat.1D | tee $outputname.co-lin.txt
 #./takepic.bash $outputname.nii.gz
 writelog "#3dNotes $(pwd)/$outputname.nii.gz"
fi

