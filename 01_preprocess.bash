#!/usr/bin/env bash

# give a subject and block (e.g C1-R4)
# and this will preprocess it

subjid=$1 
block=$2

[ -z "$subjid" -o -z "$block" ] && echo "USAGE: $0 lunaid_date B#" && exit 1;

scriptdir=$(cd $(dirname $0);pwd)
slices=$scriptdir/mMRDA_MBTimings.1D  

# get epidir and mpragedir
scriptdir=$(cd $(dirname $0);pwd)
. $scriptdir/settingsrc.bash

epi=$epidir/$block/epi.nii.gz
mprage_bet=$mpragedir/mprage_bet.nii.gz
warpcoef=$mpragedir/mprage_warpcoef.nii.gz 

[ ! -r $mprage_bet ] && echo "no $mprage_bet, process mprage first" && exit 1
[ ! -r $epi ] && echo "no $epi, run copy script" && exit 1

cd $(dirname $epi)
preprocessFunctional \
	-4d $(basename $epi)  -tr 1.5     \
	-mprage_bet $mprage_bet -warpcoef $warpcoef \
        -slice_acquisition interleaved  \
	-4d_slice_motion -custom_slice_times $slices 
        #-no_st -motion_ sinc
