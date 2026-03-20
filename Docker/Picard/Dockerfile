FROM broadinstitute/picard:3.4.0 

LABEL org.opencontainers.image.vendor="National Research Council Canada" \
      org.opencontainers.image.authors="Lars Schreiber <lars.schreiber@nrc-cnrc.gc.ca>"

### LABELS ###
LABEL base_image="Ubuntu 24.04"
LABEL software="Picard"
LABEL software.version="3.4.0"

# Install tini
RUN apt-get clean && \
    rm -R /var/lib/apt/lists/* && \
    apt-get update > /dev/null && \
    apt-get install --no-install-recommends --yes \
    ca-certificates \
    tini > /dev/null && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]