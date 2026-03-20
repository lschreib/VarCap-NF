FROM alpine:3.18

LABEL org.opencontainers.image.vendor="National Research Council Canada" \
      org.opencontainers.image.authors="Lars Schreiber <lars.schreiber@nrc-cnrc.gc.ca>"
      
#Install standard packages and Java
RUN apk update > /dev/null && \
    apk --no-cache add \
        bash \
        wget \
        bzip2 \
        ca-certificates \
        git \
        tini \
        openjdk17-jdk \
        > /dev/null && \
        rm -rf /var/cache/apk/*

#Copy BBMap from local and install (we have to do it this way as the bbmap download is hosted by Sourceforge,
#which doesn't provide a direct donwload link)
COPY BBMap_39.01.tar.gz /BBMap_39.01.tar.gz
RUN tar xvzf BBMap_39.01.tar.gz && \
    rm BBMap_39.01.tar.gz && \
    mv bbmap_modified bbmap


ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]