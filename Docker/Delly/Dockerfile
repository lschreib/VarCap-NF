FROM alpine:3.23

LABEL org.opencontainers.image.vendor="National Research Council Canada" \
      org.opencontainers.image.authors="Lars Schreiber <lars.schreiber@nrc-cnrc.gc.ca>"

### LABELS ###
LABEL base_image="alpine"
LABEL software="Delly"
LABEL software.version="1.7.3"

#Install standard packages and Java
RUN apk update > /dev/null && \
    apk --no-cache add \
        bash \
        tini \
        > /dev/null && \
        rm -rf /var/cache/apk/*

WORKDIR /app_home/delly

# Install hisat2
COPY delly-v1.7.3-linux-amd64 /app_home/delly/delly
RUN chmod 775 /app_home/delly/delly

ENV PATH=/app_home/delly:/usr/local/:$PATH
ENV SCRIPT_PATH=/app_home/delly

ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]