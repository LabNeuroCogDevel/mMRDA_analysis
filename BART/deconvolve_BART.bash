#!/usr/bin/env bash
#

funcfile=nfswkm_epi.nii.gz
mocofile=3dvolreg.par


3dDeconvolve                                           \
      -input $funcfile \
      -polort 3     -tout                              \
      -overwrite                                       \
      -num_stimts 11                                    \
      -stim_file 1 $mocofile'[0]' -stim_base 1 -stim_label 1 rx   \
      -stim_file 2 $mocofile'[1]' -stim_base 2 -stim_label 2 ry   \
      -stim_file 3 $mocofile'[2]' -stim_base 3 -stim_label 3 rz   \
      -stim_file 4 $mocofile'[3]' -stim_base 4 -stim_label 4 mx   \
      -stim_file 5 $mocofile'[4]' -stim_base 5 -stim_label 5 my   \
      -stim_file 6 $mocofile'[5]' -stim_base 6 -stim_label 6 mz   \
      \
      -stim_times 7 Reward_pump_times.1D 'GAM' \
      -stim_label 7 RewardPump                              \
      -stim_times 8 Reward_cash_times.1D 'GAM' \
      -stim_label 8 RewardCash                     \
      -stim_times 9 Reward_burst_times.1D 'GAM'    \
      -stim_label 9 RewardBurst                              \
      -stim_times 10 Control_pump_times.1D 'GAM' \
      -stim_label 10 ControlPump \
      -stim_times 11 Control_points_times.1D 'GAM' \
      -stim_label 11 ControlPoints \
      \
      -num_glt 4                                     \
      -censor  mcplots_censor.1D                     \
      -gltsym "SYM: RewardPump  -ControlPump"     -glt_label 1 RPump-CPump  \
      -gltsym "SYM: RewardCash  -ControlPoints" -glt_label 2 RCash-CPoint  \
      -gltsym "SYM: RewardPump    -RewardCash"    -glt_label 3 RPump-RCash  \
      -gltsym "SYM: RewardCash    -RewardBurst" -glt_label 4 RPoints-RBurst \
      -bucket BART_contrasts
