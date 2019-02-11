FROM ubuntu:18.04

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils \
        build-essential \ 
        sudo \
        gcc \
        g++ \
        libopenblas-dev \
        liblapacke-dev \
        libhdf5-serial-dev \
        libmatio-dev \
    && apt-get install -y make \
        -y cmake \
        -y python2.7-dev \
        python-pip \
        swig \
    && pip install numpy \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD . /openmeeg

RUN cd /openmeeg \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release -DUSE_PROGRESSBAR=ON -DBLA_VENDOR=OpenBLAS -DENABLE_PYTHON=ON .. \
    && make \
    && make test \
    && make install \
    && cd ../.. && rm -rf cppcheck*

ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib/"

ADD example.py /

CMD [ "python", "./examples/example.py"]
