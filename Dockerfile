FROM ubuntu:bionic

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8


RUN apt-get --yes -qq update \
 && apt-get --yes -qq upgrade \
 && apt-get --yes -qq install \
                      bzip2 \
                      cmake \
                      cpio \
                      curl \
                      g++ \
                      gcc \
                      gfortran \
                      git \
                      libblas-dev \
                      liblapack-dev \
                      libopenmpi-dev \
                      openmpi-bin \
                      python3-dev \
                      python3-pip \
                      wget \
                      zlib1g-dev \
                      vim       \
                      htop      \
                      openssh-server \
			net-tools \
			iputils-ping \
			mpich \
			iproute2

CMD [ "/bin/bash" ]
