### In docker container locally:

build image:

docker build   -t ghcr.io/lukas-scharf-plus/mintpy-pipeline:0.1.0   -f docker/Dockerfile .


Basic run of steps
 - 01_run_mintpy_load.sh
 - 02_run_mintpy_full.sh
 - 03_render_pngs.sh
 - 04_standardized_geocode.sh



 Parameter order:

1 = ISCE_DIR
2 = MINTPY_DIR
3 = SUBSET_LALO
4 = TROPO_METHOD
5 = MIN_TEMP_COH


Run individual scripts:


In case that rsc files can not be generated in 01_run_mintpy_load check that rsc will be created! permission issues can occur locally

docker run --rm -it   
--user root   
-v ~/projects/ADUCAT/data:/data   
ghcr.io/lukas-scharf-plus/mintpy-pipeline:0.1.0   
prep_isce.py     
-m /data/ISCE_output/stack_Descending_124_20200602_20200626_c2_z2_r6_f0.5/reference/IW2.xml     
-g /data/ISCE_output/stack_Descending_124_20200602_20200626_c2_z2_r6_f0.5/merged/geom_reference     
-b /data/ISCE_output/stack_Descending_124_20200602_20200626_c2_z2_r6_f0.5/baselines     
-f "/data/ISCE_output/stack_Descending_124_20200602_20200626_c2_z2_r6_f0.5/merged/interferograms/*/filt_fine.unw"


1. Load Data

docker run --rm -it   
-v ~/projects/ADUCAT/data:/data   
ghcr.io/lukas-scharf-plus/mintpy-pipeline:0.1.0   
/scripts/mintpy/01_run_mintpy_load.sh   
/data/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5   
/data/Mintpy_output/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5_mintpy   
"48.17:48.23,16.34:16.38"   
"no"   
"0.7"


2. Full mintpy

docker run --rm -it   
-v ~/projects/ADUCAT/data:/data   
ghcr.io/lukas-scharf-plus/mintpy-pipeline:0.1.0   
/scripts/mintpy/02_run_mintpy_full.sh   
/data/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5   
/data/Mintpy_output/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5_mintpy


3. render pngs

docker run --rm -it \
  -v ~/projects/ADUCAT/data:/data \
  ghcr.io/lukas-scharf-plus/mintpy-pipeline:0.1.0 \
  /scripts/mintpy/03_render_pngs.sh \
  /data/Mintpy_output/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5_mintpy

  4. standardized_geocode

docker run --rm -it   
-v ~/projects/ADUCAT/data:/data   
ghcr.io/lukas-scharf-plus/mintpy-pipeline:0.1.0   
/scripts/mintpy/04_standardized_geocode.sh   
/data/Mintpy_output/stack_Descending_124_20200602_20200626_c2_z2_r6_f0.5_mintpy   
"48.17:48.23,16.34:16.38"




Full wrapper script:

docker run --rm -it \
  --user root
  -v ~/projects/ADUCAT/data:/data \
  ghcr.io/lukas-scharf-plus/mintpy-pipeline:0.1.0 \
  /scripts/run_pipeline.sh \
  /data/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5 \
  /data/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5_mintpy


With ERA5 correction:

docker run --rm -it \
  --user root
  -v ~/projects/ADUCAT/data:/data \
  -e CDSAPI_URL="https://cds.climate.copernicus.eu/api" \
  -e CDSAPI_KEY="YOUR_UID:YOUR_API_KEY" \
  ghcr.io/lukas-scharf-plus/mintpy-pipeline:0.0.8 \
  /scripts/run_pipeline.sh \
  /data/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5 \
  /data/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5_mintpy \
  pyaps



### Postprocessing

5. create common mask

0.7 is the min temporal coherence now

docker run --rm -it \
  -v ~/projects/ADUCAT/data:/data \
  ghcr.io/lukas-scharf-plus/mintpy-pipeline:0.1.1 \
  /scripts/postprocess/05_create_common_mask.sh \
  /data/Mintpy_output/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5_mintpy \
  /data/Mintpy_output/stack_Descending_124_20200602_20200626_c2_z2_r6_f0.5_mintpy \
  0.7



6. apply common mask

docker run --rm -it   
-v ~/projects/ADUCAT/data:/data   
ghcr.io/lukas-scharf-plus/mintpy-pipeline:0.1.1   
/scripts/postprocess/06_apply_common_mask.sh   
/data/Mintpy_output/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5_mintpy   
/data/Mintpy_output/stack_Descending_124_20200602_20200626_c2_z2_r6_f0.5_mintpy   
/data/Mintpy_output/common_mask/common_mask.h5



7. apply common ref point

docker run --rm -it \
  -v ~/projects/ADUCAT/data:/data \
  ghcr.io/lukas-scharf-plus/mintpy-pipeline:0.1.1 \
  /scripts/postprocess/07_apply_common_reference.sh \
  /data/Mintpy_output/stack_Ascending_73_20200604_20200628_c2_z2_r6_f0.5_mintpy \
  /data/Mintpy_output/stack_Descending_124_20200602_20200626_c2_z2_r6_f0.5_mintpy


7. LOS decomposition









## References

This workflow uses the following open-source software:

- MintPy

If you use this workflow in scientific work, please cite:

Yunjun, Z., Fattahi, H., & Amelung, F. (2019).
*Small baseline InSAR time series analysis: Unwrapping error correction and noise reduction*.
Computers & Geosciences, 133, 104331.
https://doi.org/10.1016/j.cageo.2019.104331

MintPy repository:
https://github.com/insarlab/MintPy