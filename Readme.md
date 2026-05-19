### In docker container locally:

build image:

docker build   -t ghcr.io/lukas-scharf-plus/mintpy-pipeline:0.0.8   -f docker/Dockerfile .


Basic run of steps
 - 01_run_mintpy_load.sh
 - 02_run_mintpy_full.sh
 - 03_render_pngs.sh
 - 04_standardized_geocode.sh



 Parameter order:

1 = ISCE_DIR
2 = MINTPY_DIR
3 = TROPO_METHOD
4 = MIN_TEMP_COH


docker run --rm -it \
  --user root
  -v ~/projects/ADUCAT/data:/data \
  ghcr.io/lukas-scharf-plus/mintpy-pipeline:0.0.8 \
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