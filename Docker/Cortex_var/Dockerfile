FROM condaforge/mambaforge:23.11.0-0

ENV DEBIAN_FRONTEND=noninteractive

### LABELS ###
LABEL base_image="ubuntu jammy"
LABEL software="Cortex_var"
LABEL software.version="1.0.5"

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
RUN git clone --recursive https://github.com/iqbal-lab/cortex.git && \
    cd cortex && \
    bash install.sh && \
    make cortex_var && \
    make cortex_var MAXK=63 NUM_COLS=1

# Install vcftools
RUN git clone https://github.com/vcftools/vcftools.git && \
    cd vcftools && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

WORKDIR /app_home

RUN curl -o minimap2.tar.bz2 -L https://github.com/lh3/minimap2/releases/download/v2.30/minimap2-2.30_x64-linux.tar.bz2 && \
    tar -jxvf minimap2.tar.bz2 && \
    mv minimap2-2.30_x64-linux minimap2 && \
    rm minimap2.tar.bz2
   
ENV PATH="/app_home/minimap2:$PATH"

ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]
