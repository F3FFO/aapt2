#!/bin/bash

sudo apt install \
golang \
ninja-build \
autogen \
autoconf \
libtool \
build-essential \
-y || exit 1

cd "src/protobuf" || exit 1
./autogen.sh
./configure
make -j"$(nproc)"
sudo make install
sudo ldconfig