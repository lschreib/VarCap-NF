FROM alpine:3.23

LABEL org.opencontainers.image.vendor="National Research Council Canada" \
      org.opencontainers.image.authors="Lars Schreiber <lars.schreiber@nrc-cnrc.gc.ca>"

### LABELS ###
LABEL base_image="alpine"
LABEL software="SeqTK"
LABEL software.version="1.7.3"

#Install standard packages and Java
RUN apk update > /dev/null && \
    apk --no-cache add \
        gzip \
        build-base \
        zlib-dev \
        gcc \
        wget \
        git \
        bash \
        tini \
        > /dev/null && \
        rm -rf /var/cache/apk/*

WORKDIR /app_home

# Install seqtk from git
RUN git clone https://github.com/lh3/seqtk.git &&\
    cd seqtk &&\
    make

ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]