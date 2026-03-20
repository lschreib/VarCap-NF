FROM alpine:3.23

LABEL org.opencontainers.image.vendor="National Research Council Canada" \
      org.opencontainers.image.authors="Lars Schreiber <lars.schreiber@nrc-cnrc.gc.ca>"

### LABELS ###
LABEL base_image="alpine"
LABEL software="VarScan2"
LABEL software.version="2.3.9"

#Install standard packages and Java
RUN apk update > /dev/null && \
    apk --no-cache add \
        bash \
        ca-certificates \
        tini \
        openjdk17-jdk \
        > /dev/null && \
        rm -rf /var/cache/apk/*

WORKDIR /app_home/varscan2

# Install hisat2
COPY VarScan.v2.3.9.jar /app_home/varscan2/VarScan.jar

ENV PATH=/app_home/varscan2:/usr/local/:$PATH
ENV SCRIPT_PATH=/app_home/varscan2

ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]