FROM ubuntu:jammy

RUN apt-get update > /dev/null && \
    apt-get install --no-install-recommends --yes \
    bzip2 \
    gzip \
    make \
    gcc \
    tini \
    wget \
    libncurses5-dev \
    libncursesw5-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4 \
    libcurl4-openssl-dev \
    libssl-dev \
    libz-dev \
    zlib1g > /dev/null && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#Download exonerate using wget and set up
RUN cd /usr/bin && \
    wget --no-check-certificate https://github.com/samtools/samtools/releases/download/1.23/samtools-1.23.tar.bz2 && \
    tar jxvf samtools-1.23.tar.bz2 && \
    cd samtools-1.23 && \
    sed -i.bak 's/LIBCURSES\=  -lcurses/LIBCURSES\=  -lncurses/g' Makefile && \
    make && \
    cd .. && \
    cp samtools-1.23/samtools . && \
    rm samtools-1.23.tar.bz2

ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]