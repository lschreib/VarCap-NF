FROM ubuntu:jammy

RUN apt-get update > /dev/null && \
    apt-get install --no-install-recommends --yes \
    bzip2 \
    gzip \
    openjdk-18-jre \
    unzip \
    tini \
    fastqc > /dev/null && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]