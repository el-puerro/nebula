#!/usr/bin/env bash

set -e 
set -x 

export PREFIX="$(pwd)/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

export ROOTDIR=$(pwd)

cd $ROOTDIR/src

mkdir build-binutils
cd build-binutils

../binutils/configure \
    --target=$TARGET \
    --prefix="$PREFIX" \
    --with-sysroot \
    --disable-nls \
    --disable-werror

make
make install 

cd $ROOTDIR/src

# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which -- $TARGET-as || echo $TARGET-as is not in the PATH

mkdir build-gcc
cd build-gcc

../gcc/configure \
    --target=$TARGET \
    --prefix="$PREFIX" \
    --disable-nls \
    --enable-languages=c,c++ \
    --without-headers

make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc
