FROM python:3.10 as o2scl

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        g++ \
        make \
        libgsl-dev \
        autoconf \
        automake \
        libtool \
        git \
        libhdf5-dev \
        libncurses-dev \
        libreadline-dev \
        libboost-all-dev \
        libeigen3-dev \
        cmake \
        libopenblas-dev \
        liblapack-dev \
        libarpack2-dev \
        libsuperlu-dev \
        libarmadillo-dev \
        libfftw3-dev \
        curl \
        python3 \
        python3-pip \
        texlive \
        dvipng \
        texlive-latex-extra \
        cm-super \
        libyaml-cpp-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install \
    numpy \
    scipy \
    yt \
    matplotlib \
    requests \
    pytest \
    Pillow \
    scikit-learn \
    tensorflow-cpu\
    --no-binary=h5py h5py

ENV LD_LIBRARY_PATH /usr/local/lib
# RUN acol -h ## acol -h executes successfully here
ENV HDF5_DIR=/usr/lib/x86_64-linux-gnu/hdf5/serial

WORKDIR /opt
RUN git clone https://github.com/awsteiner/o2scl && \
    cd o2scl && \
    git checkout dcf7262930a1253d9b654f39a8ae9ad886935ea8

WORKDIR /opt/o2scl
RUN autoreconf -i
RUN export LDFLAGS="-larmadillo -llapack -lblas -lncurses" && \
    export CXXFLAGS="" && \
    export CXXFLAGS="${CXXFLAGS} -O3 -DO2SCL_UBUNTU_HDF5 -DO2SCL_HDF5_PRE_1_12 -DO2SCL_REGEX -DO2SCL_HDF5_COMP" && \
    export CXXFLAGS="${CXXFLAGS} -I/usr/include -I/usr/lib/x86_64-linux-gnu/hdf5/serial/include" && \
    export CXXFLAGS="${CXXFLAGS} -I/usr/local/lib/python3.10/site-packages/numpy/core/include" && \
    ./configure --enable-eigen --enable-armadillo --enable-openmp --enable-fftw --enable-python
RUN make blank-doc \
    make -j 4 \
    make install


FROM python:3.10 as o2sclpy
WORKDIR /opt
RUN git clone https://github.com/awsteiner/o2sclpy /opt/o2sclpy && \
    cd /opt/o2sclpy && \
    git checkout f3fe1b79af6b8a040e963e24313f5ded87baa2b2 \
    pip install .


FROM python:3.10 as utk_eos

# UTK EOS
WORKDIR /opt
RUN git clone https://github.com/awsteiner/eos
WORKDIR /opt/eos
RUN git switch v2 && \
    git checkout 40d06b65bbc1f73c2bccab7d5e5e98ff686b1ee5
    

#COPY requirements.txt requirements.txt
#RUN pip install -r requirements.txt

#COPY --from=o2sclpy /usr/local/lib/python3.10/site-packages/o2sclpy /usr/local/lib/python3.10/site-packages/o2sclpy
#COPY --from=o2scl /opt/o2scl /opt/o2scl
