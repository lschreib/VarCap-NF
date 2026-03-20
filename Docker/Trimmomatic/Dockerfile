FROM alpine:3.18

LABEL org.opencontainers.image.vendor="National Research Council Canada" \
      org.opencontainers.image.authors="Lars Schreiber <lars.schreiber@nrc-cnrc.gc.ca>"
      
#Install standard packages, Java (for Trimmomatic) and Perl (stats summary afterwards)
RUN apk update > /dev/null && \
    apk --no-cache add \
        bash \
        wget \
        bzip2 \
        ca-certificates \
        git \
        tini \
        openjdk17-jdk \
        perl \
        unzip \
        > /dev/null && \
        rm -rf /var/cache/apk/*

#Download and install Trimmomatic
RUN wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.39.zip && \
    unzip Trimmomatic-0.39.zip && \
    mv Trimmomatic-0.39 trimmomatic && \
    rm Trimmomatic-0.39.zip

ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]