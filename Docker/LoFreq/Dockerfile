FROM condaforge/mambaforge:23.11.0-0

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

### LABELS ###
LABEL base_image="mambaforge"
LABEL software="LoFreq* docker"
LABEL software.version="2.1.5"

### Basic dependency ###
RUN apt-get clean all && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y  \
    build-essential \
    tini \
    zlib1g-dev > /dev/null && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/*

ENV PATH=/opt/conda/bin:$PATH

### install GetOrganelle through bioconda ###
RUN conda config --add channels conda-forge && \
    conda config --add channels bioconda && \
    mamba create -n LoFreq && \
    mamba install -n LoFreq -c bioconda -c conda-forge -y lofreq=2.1.5

RUN echo "source activate LoFreq" > ~/.bashrc
ENV PATH=/opt/conda/envs/LoFreq/bin:$PATH

ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]