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
patch -p1 --ignore-whitespace -i ../0006-surface-i915.patch

# make config file based off of running config
yes '' | make oldconfig

# update the .config for surface button in case this is the first time build
sed -i 's/# CONFIG_SURFACE_PRO3_BUTTON is not set/CONFIG_SURFACE_PRO3_BUTTON=m/g' .config

# build it
make clean
make -j `getconf _NPROCESSORS_ONLN` deb-pkg LOCALVERSION=-reeps

# move the build output to build after cleaning up old stuff
rm -rf build
mkdir build
mv linux-* build/
