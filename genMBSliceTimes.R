## Script developed by MH 2014
## adapted 20140319 (WF)

##output approximate slice times for MB data
##From Tae Kim email dated 2/26:
##Each slice took 83 ms, and 12 slices for each TR acquired with interleaved order, 9, 5, 1, 10, 6, 2, 11, 7, 3, 12, 8, 4.
##Used 5x acceleration, so need to replicate this for every 12 slices
##asked Tae about this Dec2013, he says look at slice times in dicom header
##these indicate by time: 2, 4, 6, 7, 10, 12, 1, 3, 5, 7, 9, 11

tr <- 1.0
#baseTiming <- c(9, 5, 1, 10, 6, 2, 11, 7, 3, 12, 8, 4) #shift to zero-based timing
#baseTiming <- c(2, 4, 6, 8, 10, 12, 1, 3, 5, 7, 9, 11) #interleaved ascending, even first
#but apparently times are not exactly even (appear to be rounded to 2.5ms resolution)
#fromHeaderTimes <- c(500, 0, 585, 82.5, 667.5, 167.5, 752.5, 250, 835, 335, 920, 417.5)/1000 #bottom to top, in seconds
#  sort(fromHeaderTimes,index.return=T)$ix
#   2  4  6  8 10 12  1  3  5  7  9 11
# ie. get bottom second, one up from botton fourth,  

# interleaved, odd first
fromHeaderTimes <- c(0, 802.953, 100.366, 903.351, 200.733, 1003.71, 301.121, 1104.07,401.487, 1204.47, 501.853, 1304.82, 602.231, 1405.17, 702.586)/1000
# ^^ above from:
# bash: for f in *; do dicom_hdr -slice_times $f; done > stfor-epi13
# a<-read.table('stfor-epi13')[-c(1:5)]
# signif(unname(colMeans(a)),6))
# should be intervals of 100ms, but timing is +/- 2.5ms -- so averaged over one run

nsimultaneous <- 3 #  number of slices excited at once (acceleration)
nslices <- nsimultaneous*length(fromHeaderTimes)
timing <- tcrossprod(fromHeaderTimes, rep(1, nsimultaneous)) #replicate timings vector 5x

sink("mMRDA_MBTimings.1D")
cat(paste(as.vector(timing), collapse=","), "\n")
sink()

