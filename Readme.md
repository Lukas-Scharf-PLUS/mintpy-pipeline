Run mintpy

First try:

docker run --rm -it \
  --user root \
  -v ~/projects/ADUCAT/data:/workspace/data \
  -w /workspace/data/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5 \
  ghcr.io/insarlab/mintpy:v1.6.3-26-gf02ee975 \
  bash


You should be here:

(base) root@89288c6c844d:/workspace/data/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5# ls

ESD                    coreg_secondarys  logs        parameters.log  secondarys
baselines              geom_reference    merged      pic             smallbaselineApp.cfg
coarse_interferograms  input_scenes.txt  mintpy.cfg  reference       stack
configs                interferograms    misreg      run_files       timing.log


basic config:

mintpy.load.processor = isce

mintpy.load.metaFile = ./reference/IW*.xml
mintpy.load.baselineDir = ./baselines
mintpy.load.unwFile = ./merged/interferograms/*/filt_fine.unw
mintpy.load.corFile = ./merged/interferograms/*/filt_fine.cor
mintpy.load.geomDir = ./merged/geom_reference

mintpy.reference.yx = auto
mintpy.networkInversion.method = weighted
mintpy.temporalCoherence.min = 0.7

mintpy.troposphericDelay.method = no


smallbaselineApp.py mintpy.cfg --end load_data

... 
################################################
   Normal end of smallbaselineApp processing!
################################################
Time used: 00 mins 5.9 secs

check inputs:

cd inputs

There should be:
geometryRadar.h5  ifgramStack.h5  mintpy.cfg  smallbaselineApp.cfg

run full mintpy: 

smallbaselineApp.py mintpy.cfg

Check:
ls *.h5

view.py velocity.h5 velocity


### In docker container locally:

build image:

docker build \
  -t mintpy-pipeline:0.0.1 \
  -f docker/Dockerfile \
  .