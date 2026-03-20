# =============================================================================
# Manifest
# -----------------------------------------------------------------------------
# Name:          multiqc-env
# Version:       1.0
# Base Image:    python:3.11-slim
# Description:   Environment with build tools and Python 3 for running MultiQC
# Maintainer:   Lars Schreiber <lars.schreiber@nrc-cnrc.gc.ca>
# Tools Installed:
#   - build-essential, wget, unzip, git
#   - curl, autoconf, automake, libssl-dev, rsync, gzip, tini
#   - procps (necessary so that we can monitor processes and resource usage using 'ps' in Nextflow)
# Pip Packages:
#   - multiqc==1.30
# Entry Point:   tini -- /bin/bash
# Notes:
#   - `tini` handles zombie reaping and signal forwarding as PID 1.
#   - `apt-get clean` and list removal reduce image size.
# =============================================================================

FROM python:3.11-slim

RUN apt-get update && \
    apt-get install --no-install-recommends --yes \
    build-essential \
    wget \
    unzip \
    git \
    curl \
    autoconf \
    automake \
    libssl-dev \
    rsync \
    gzip \
    tini \
    procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install multiqc==1.30 pandoc

ENTRYPOINT ["tini", "--"]
CMD ["/bin/bash"]