FROM ghcr.io/insarlab/mintpy:v1.6.3-26-gf02ee975

WORKDIR /workspace

RUN pip install --no-cache-dir \
    cdsapi \
    pyaps3 \
    ecmwf-datastores-client

COPY scripts/ /scripts/