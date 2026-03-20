FROM ghcr.io/iqbal-lab-org/clockwork:latest

ENV DEBIAN_FRONTEND=noninteractive

### LABELS ###
LABEL base_image="ubuntu jammy"
LABEL software="Cortex_var"
LABEL software.version="1.0.5"

#-----------------------------
#1. System dependencies
#-----------------------------
RUN apt-get clean && \
    rm -R /var/lib/apt/lists/* && \
    apt-get update > /dev/null && \
    apt-get install --no-install-recommends --yes \
    tini \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]
