FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8
ENV TZ 'America/Indiana/Indianapolis'
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone  && \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  git \
  libncurses5-dev zlib1g-dev libbz2-dev liblzma-dev libcurl3-dev \
  pigz \
  perl \
  wget \
  && cd /usr/local/bin \
  && apt-get clean && apt-get purge \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## set up tool config and deployment area:
COPY xenome /usr/local/bin/
    
RUN wget -qO- https://github.com/shenwei356/csvtk/releases/download/v0.24.0/csvtk_linux_amd64.tar.gz | tar -xz     && cp csvtk /usr/local/bin/

WORKDIR /mnt
