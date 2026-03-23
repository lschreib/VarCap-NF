FROM python:3.11-slim

RUN apt-get update && \
    apt-get install --no-install-recommends --yes \
    build-essential \
    wget \
    unzip \
    git \
    curl \
    autoconf \
    automake \
    libssl-dev \
    rsync \
    gzip \
    tini \
    procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip && \
    pip install genbank_to
# This actually already includes a basic Perl installation 

ENTRYPOINT ["tini", "--"]
CMD ["/bin/bash"]