#! /bin/bash

set -e
set -x

if [[ "$ARCH" == "" ]]; then
    echo "Usage: env ARCH=... bash $0"
    exit 2
fi

# TODO: fix inconsistency in architecture naming *everywhere*
docker_arch=

case "$ARCH" in
    "x86_64")
        export ARCH="x86_64"
        docker_dist=centos7
        ;;
    "i386"|"i686")
        export ARCH="i686"
        docker_arch="i386"
        docker_dist=centos7
        ;;
    armhf|aarch64)
        docker_dist=xenial
        ;;
    *)
        echo "Unknown architecture: $ARCH"
        exit 3
        ;;
esac

# make sure we're in the repository root directory
this_dir="$(readlink -f "$(dirname "$0")")"
repo_root="$this_dir"/..

# docker image name
docker_image=quay.io/appimage/appimagebuild:"$docker_dist"-"${docker_arch:-$ARCH}"
# make sure it's up to date
docker pull "$docker_image"

# prepare output directory
mkdir -p out/

# we run all builds with non-privileged user accounts to make sure the build doesn't depend on such features
uid="$(id -u)"

# note: we cannot just use '-e ARCH', as this wouldn't overwrite the value set via ENV ARCH=... in the image
common_docker_opts=(
    -e TERM="$TERM"
    -e ARCH="$ARCH"
    -i
    -v "$repo_root":/ws
    -v "$(readlink -f out/)":/out
)

# make ctrl-c work
if [[ "$CI" == "" ]] && [[ "$TERM" != "" ]]; then
    common_docker_opts+=("-t")
fi

# build runtime
# note: we enforce using the same UID in the container as outside, so that the created files are owned by the caller
docker run --rm \
    --user "$uid" \
    "${common_docker_opts[@]}" \
    "-v" "$HOME"/.gnupg:/root/.gnupg \
    "$docker_image" \
    /bin/bash -xc "cd /out && /ws/ci/build.sh"

ls -al out/

# make sure the runtime contains the magic bytes
hexdump -Cv out/runtime | head -n 1 | grep "41 49 02 00"
# fix filename for upload
mv out/runtime out/runtime-"$ARCH"
