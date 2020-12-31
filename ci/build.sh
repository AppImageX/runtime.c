#! /bin/bash

set -e
set -x
set -o functrace

# make sure the prebuilt libraries in the container will be found
# (in case we're building in an AppImageBuild container)
export LD_LIBRARY_PATH=/deps/lib:"$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH=/deps/lib/pkgconfig/
export PATH=/deps/bin:"$PATH"

# we always build in a temporary directory
# use RAM disk if possible
if [ -d /dev/shm ] && mount | grep /dev/shm | grep -v -q noexec; then
    TEMP_BASE=/dev/shm
elif [ -d /docker-ramdisk ]; then
    TEMP_BASE=/docker-ramdisk
else
    TEMP_BASE=/tmp
fi

BUILD_DIR="$(mktemp -d -p "$TEMP_BASE" runtime.c-build-XXXXXX)"

cleanup () {
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
    fi
}

trap cleanup EXIT

REPO_ROOT="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")"/..)"
OLD_CWD="$(readlink -f .)"

pushd "$BUILD_DIR"

# configure build and generate build files
cmake "$REPO_ROOT" \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release

# run build
if [[ "$CI" != "" ]]; then
    nproc="$(nproc)"
else
    nproc="$(nproc --ignore=1)"
fi

# it's sufficient to just build the runtime target
make -j"$nproc" runtime

# print first few bytes in runtime
# allows checking whether the magic bytes are in place
xxd src/runtime | head -n1

# copy runtime to original working directory
cp src/runtime "$OLD_CWD"/
