### In docker container locally:

build image:

docker build \
  -t mintpy-pipeline:0.0.2 \
  -f docker/Dockerfile \
  .


docker run --rm   
--user root   
-v ~/projects/ADUCAT/data:/workspace/data   
mintpy-pipeline:0.0.2   
/scripts/run_pipeline.sh   
/workspace/data/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5   
/workspace/data/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5_mintpy