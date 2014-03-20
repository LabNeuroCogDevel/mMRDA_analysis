# Processes MRI from mMR PET/MRI

## TODO
* 0026 is 10672_20140318, rename
* run 3dDeconvolve

## Data and Paths

### sources

  * this script lives on wallace in `/data/Luna1/mMRDA-dev/scripts`
  * data from TK is in `/data/Luna1/mMRDA-dev/functional/`
     - originally sent to `skynet:/Volumes/Serena/mMRDA-dev/MR_Raw`
  * raw data is `/data/Luna1/Raw/mMRDA-dev/`
     - func/c11-rac copied from: `/disk/mace2/scan_data/DEV-LUNA/`
     - struct/VMAT  copied from: `/disk/mace2/scan_data/homeless/BRAIN^dev-luna2/` 

### Organization
  * `scripts -- this directory
  * `behav` -- mat files for both slot task and BART
  * `FS_Subjects` -- FreeSurfer parcelations
  * `functional`  -- the arrange functional scans 
     - `C1 - C4` -- Slot Task Sensory Motor Control blocks
     - `R1 - R4` -- Slot Task Reward block
     - `BART`  -- Ballon Analogue Risk Task
     - `Rest`  -- resting/no task
  * `mprage` 
     - `func`  -- anatomical T1 from functional (c11-rac.) session
     - `struct`  -- anatomical T1 from structural (DTBZ/VMAT) session
  * `raw` -- symbolic link to raw 

## Scripts

### Pipeline

see `processing.bash`

  1. copy/organize, reformat (hdr/img -> nii) 
  1. warp mprage
  1. FreeSurfer
  1. preprocess functional 
  1. generate 3dDeconvolve contrasts

### Notes
  * need v.4 of nipy:

     pip install git+https://github.com/nipy/nipy/ 

  * preprocess* and sliceMotion4D copied from skynet 20140320 (lack `svn up` permssion)


