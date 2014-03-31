#!/usr/bin/env bash

# give a subject and block (e.g C1-R4)
# and this will preprocess it

subjid=$1 
block=$2
quick=$3

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


motionandslice="-slice_acquisition interleaved  -4d_slice_motion -custom_slice_times $slices"

# if 3rd option is quick, dont do slice and do fast motion correction
[ "$quick x" == "quick x" ] && motionandslice="-no_st -motion_sinc n"

cd $(dirname $epi)
preprocessFunctional \
	-4d $(basename $epi)  -tr 1.5     \
	-mprage_bet $mprage_bet -warpcoef $warpcoef \
        $motionandslice


writelog "$0 $@"
