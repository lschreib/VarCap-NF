FROM rocker/r-ver:4.5
RUN echo 'options(repos = c(CRAN = "https://cloud.r-project.org"))' >>"${R_HOME}/etc/Rprofile.site"

LABEL org.opencontainers.image.vendor="National Research Council Canada" \
      org.opencontainers.image.authors="Lars Schreiber <lars.schreiber@nrc-cnrc.gc.ca>"

### LABELS ###
LABEL base_image="r-ver"
LABEL software="VarCap"
LABEL software.version="1.0.0"

#INstall necessary system packages (all the lib* things are necessary to extend the image with additional R packages)      
RUN apt-get update > /dev/null && \
    apt-get install --no-install-recommends --yes \
        wget bzip2 ca-certificates \
        coreutils \
        gawk \
        grep \
        sed \        
        git \
        tini \
        perl \
        libfile-slurp-perl \
        cpanminus \
        python3 \
        pip \
        openjdk-17-jdk \
        libxml2 \
        libxt6 \
        zlib1g-dev \
        libbz2-dev \
        liblzma-dev \
        libpcre3-dev \
        libicu-dev \
        libjpeg-dev \
        libpng-dev \
        libxml2-dev \
        libgdal-dev \
        libglpk-dev \
        libcurl4-openssl-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libcurl4 \
        libssl-dev \
        libz-dev \
        build-essential \
        unzip \
        curl \
        autoconf \
        automake \
        rsync \
        gzip \
        pigz \
        procps \
        > /dev/null && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install necessary R packages
RUN install2.r optparse readr ggplot2 && \
    rm -rf /tmp/downloaded_packages

# Install genbank_to
RUN pip install genbank_to --break-system-packages

# Install Samtools
COPY samtools-1.23.tar.bz2 /usr/bin/samtools-1.23.tar.bz2
RUN cd /usr/bin && \
    tar jxvf samtools-1.23.tar.bz2 && \
    cd samtools-1.23 && \
    sed -i.bak 's/LIBCURSES\=  -lcurses/LIBCURSES\=  -lncurses/g' Makefile && \
    make && \
    cd .. && \
    cp samtools-1.23/samtools . && \
    rm samtools-1.23.tar.bz2

WORKDIR /app_home
# Install VMatch & MKVTree
COPY vmatch-2.3.1-Linux_x86_64-64bit.tar.gz /app_home/vmatch-2.3.1-Linux_x86_64-64bit.tar.gz
RUN tar -xvzf vmatch-2.3.1-Linux_x86_64-64bit.tar.gz && \
    mv vmatch-2.3.1-Linux_x86_64-64bit vmatch && \
    rm vmatch-2.3.1-Linux_x86_64-64bit.tar.gz

ENV PATH="/app_home/vmatch:$PATH"

# Install VarCap package
COPY varcap_v3.0.tar.gz /app_home/varcap_v3.0.tar.gz
RUN tar -xvzf varcap_v3.0.tar.gz && \
    rm varcap_v3.0.tar.gz

ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]