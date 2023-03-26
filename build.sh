#!/bin/bash

if [[ -z "${NDK_TOOLCHAIN}" ]]; then
    echo "Please specify the Android NDK environment variable \"NDK_TOOLCHAIN\"."
    exit 1
fi

ROOT_DIR="$(pwd)"

chmod +x ./script/install-prerequisites.sh
chmod +x ./script/git-patch.sh

script/./install-prerequisites.sh
cd "$ROOT_DIR" || exit 1
script/./git-patch.sh

# Define all the compilers, libraries and targets.
MIN_SDK_VERSION="30"
ARCH=$1
declare -A compilers=(
    [x86_64]=x86_64-linux-android
    [x86]=i686-linux-android
    [arm64-v8a]=aarch64-linux-android
    [armeabi-v7a]=armv7a-linux-androideabi
)
declare -A lib_arch=(
    [x86_64]=x86_64-linux-android
    [x86]=i686-linux-android
    [arm64-v8a]=aarch64-linux-android
    [armeabi-v7a]=arm-linux-androideabi
)
declare -A target_abi=(
    [x86_64]=x86_64
    [x86]=x86
    [arm64-v8a]=aarch64
    [armeabi-v7a]=arm
)

build_directory="build"
aapt_binary_path="$ROOT_DIR/$build_directory/cmake/aapt2"
# Build all the target architectures.
bin_directory="$ROOT_DIR/dist/$ARCH"

# switch to cmake build directory.
[[ -d dir ]] || mkdir -p $build_directory && cd $build_directory || exit 1

# Define the compiler architecture and compiler.
TARGET_HOST="${compilers[$ARCH]}"
C_COMPILER="$TARGET_HOST$MIN_SDK_VERSION-clang"
CXX_COMPILER="${C_COMPILER}++"

# Copy libc++.a to libpthread.a.
lib_path="$NDK_TOOLCHAIN/sysroot/usr/lib/${lib_arch[$ARCH]}/$MIN_SDK_VERSION"
cp -n "$lib_path/libc++.a" "$lib_path/libpthread.a"

# Run make for the target architecture.
compiler_bin_directory="$NDK_TOOLCHAIN/bin/"
cmake -GNinja \
-DCMAKE_C_COMPILER="$NDK_TOOLCHAIN/bin/$C_COMPILER" \
-DCMAKE_CXX_COMPILER="$NDK_TOOLCHAIN/bin/$CXX_COMPILER" \
-DCMAKE_BUILD_WITH_INSTALL_RPATH=True \
-DCMAKE_BUILD_TYPE=Release \
-DANDROID_ABI="$ARCH" \
-DTARGET_ABI="${target_abi[$ARCH]}" \
-DPROTOC_PATH="/usr/local/bin/protoc" \
-DCMAKE_SYSROOT="$NDK_TOOLCHAIN/sysroot" \
.. || exit 1

ninja || exit 1

"$NDK_TOOLCHAIN/bin/llvm-strip" --strip-unneeded  "$aapt_binary_path"

# Create bin directory.
mkdir -p "$bin_directory"

# Move aapt2 to bin directory.
mv "$aapt_binary_path" "$bin_directory"

exit 0