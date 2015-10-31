#!/bin/bash

rm -rf linux.old
mv linux linux.old

git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

cd linux
patch -p1 --ignore-whitespace -i ../0001-base-packaging.patch
patch -p1 --ignore-whitespace -i ../0002-debian-changelog.patch
patch -p1 --ignore-whitespace -i ../0003-configs-based-on-Ubuntu-4.3.0-1.5.patch
patch -p1 --ignore-whitespace -i ../0004-surface-cam.patch
patch -p1 --ignore-whitespace -i ../0005-surface-touchpad.patch

yes '' | make oldconfig
make clean
make -j `getconf _NPROCESSORS_ONLN` deb-pkg LOCALVERSION=-reeps
