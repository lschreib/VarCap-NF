FROM ubuntu:jammy

LABEL org.opencontainers.image.vendor="National Research Council Canada" \
      org.opencontainers.image.authors="Lars Schreiber <lars.schreiber@nrc-cnrc.gc.ca>"

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

### LABELS ###
LABEL software="bwa-mem2 docker"
LABEL software.version="2.3"

# Install tini
RUN apt-get update \
 && apt-get install -y --no-install-recommends tini bzip2 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app_home

# Install hisat2
COPY bwa-mem2-2.3_x64-linux.tar.bz2 /app_home/bwa-mem2-2.3_x64-linux.tar.bz2
RUN tar -xf bwa-mem2-2.3_x64-linux.tar.bz2 \
    && mv /app_home/bwa-mem2-2.3_x64-linux /app_home/bwa-mem2

ENV PATH=/app_home/bwa-mem2:/usr/local/:$PATH
ENV SCRIPT_PATH=/app_home/bwa-mem2

WORKDIR /app_home/bwa-mem2

ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]