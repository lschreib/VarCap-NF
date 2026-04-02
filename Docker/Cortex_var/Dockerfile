FROM condaforge/mambaforge:23.11.0-0

ENV DEBIAN_FRONTEND=noninteractive

### LABELS ###
LABEL base_image="ubuntu jammy"
LABEL software="Cortex_var"
LABEL software.version="1.0.5"

# NOTE:: Cortex has a lot of implicit requirements that are mentioned nowhere in the 
# manual, e.g.:
# - R
# - compliled cortex binaries each kmer value intended for 2 colors
# - Minimap2 (which silently replaced the Stampy requirement)

RUN apt-get clean && \
    rm -R /var/lib/apt/lists/* && \
    apt-get update > /dev/null && \
    apt-get install --no-install-recommends --yes \
    build-essential \
    curl \
    tini \
    git \
    zlib1g-dev \
    libpython2.7 \
    libpython2.7-dev \
    autoconf \
    automake \
    pkg-config \
    r-base \
    && rm -rf /var/lib/apt/lists/*

# Install Cortex_var
# (we will use a local archive in case the underlying GitHub changes in the future)
COPY cortex-00a049c.tar.gz /tmp_cortex.tar.gz
RUN tar -xzf tmp_cortex.tar.gz && \
    rm tmp_cortex.tar.gz && \
    mv cortex-* cortex && \
    cd cortex && \
    bash install.sh && \
    make cortex_var MAXK=31 NUM_COLS=1 && \
    make cortex_var MAXK=31 NUM_COLS=2 && \
    make cortex_var MAXK=63 NUM_COLS=1 && \
    make cortex_var MAXK=63 NUM_COLS=2

# Install vcftools
COPY vcftools-1f87a83.tar.gz /tmp_vcftools.tar.gz
RUN tar -xzf tmp_vcftools.tar.gz && \
    rm tmp_vcftools.tar.gz && \
    mv vcftools-* vcftools && \
    cd vcftools && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

WORKDIR /app_home

COPY minimap2-2.30_x64-linux.tar.bz2 /app_home/tmp_minimap2.tar.bz2
RUN tar -jxvf tmp_minimap2.tar.bz2 && \
    rm tmp_minimap2.tar.bz2 && \
    mv minimap2-2.30_x64-linux minimap2
   
ENV PATH="/app_home/minimap2:/cortex:/vcftools/src/perl:$PATH"

ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]
