#!/bin/sh

# https://stackoverflow.com/a/45181694/327648

OS="$(uname -s)"
if [ "$OS" = "Linux" ]; then
    NPROCS="$(nproc --all)"
elif [ "$OS" = "Darwin" ] || \
        [ "$(echo "$OS" | grep -q BSD)" = "BSD" ]; then
    NPROCS="$(sysctl -n hw.ncpu)"
else
    NPROCS="$(getconf _NPROCESSORS_ONLN)"  # glibc/coreutils fallback
fi
echo "$NPROCS"