#!/bin/bash

git apply patches/incremental_delivery.patch --whitespace=fix
git apply patches/libpng.patch --whitespace=fix
git apply patches/selinux.patch  --whitespace=fix
git apply patches/protobuf.patch --whitespace=fix
git apply patches/aapt2.patch --whitespace=fix
git apply patches/androidfw.patch --whitespace=fix
git apply patches/boringssl.patch --whitespace=fix