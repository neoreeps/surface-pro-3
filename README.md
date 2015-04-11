# Ubuntu Kernel - Surface Pro 3
This is a work in progress and will be obsolete at some point when all changes make it upstream.

Most of this work is not my own, rather it is a collection of patches and instructions to simplify running Linux on Surface Pro 3.

A [Google Group](https://groups.google.com/forum/?hl=en#!forum/linux-surface) has also been created by another enthusiast to use as a discussion board for issues/successes when using Linux on SP3.  This group, specifically the first post, is where I received much of this information, along with kernel bug [84651](https://bugzilla.kernel.org/show_bug.cgi?id=84651)

- battery.patch - patch to allow the battery to be enumerated and displays accurate capacity
- cam.patch - camera patch
- buttons1.patch - adds support for power, home, volume buttons
- buttons2.patch - helps with sleep fix

## What doesn't work
* suspend - it's flaky and resumes quickly
* trackpad - it's registered as a mouse but is usable IMHO

## Get the kernel
From [Ubuntu Kernel Git Guide](https://wiki.ubuntu.com/Kernel/Dev/KernelGitGuide?action=show&redirect=KernelTeam%2FKernelGitGuide)

```
sudo apt-get install git
mkdir ~/source && cd ~/source
git clone git://kernel.ubuntu.com/ubuntu/ubuntu-vivid.git
```

## Apply the patches and Build
Copy or download the above patches and apply each of them with:
```
patch -p1 --ignore-whitespace -i {patch}
```

Before building the kernel, I update the version number to avoid software update from constantly overwriting (or attempting to) my kernel.  Simply edit ubuntu-vivid/debian.master/changelog and increment the version number by 1.
```
example: 3.19.0-13.13 -> 3.19.0-13.14
```

Build your new kernel with:
```
fakeroot debian/rules clean
DEB_BUILD_OPTIONS=parallel=4 AUTOBUILD=1 NOEXTRAS=1 fakeroot debian/rules binary-generic
```

## Install the kernel
**I have found that sometimes after touching grub, the first boot may take a few minutes.  DO NOT STOP IT, let the system boot.  Afterwards, should be fast again.**
Also, always remember to run grub-install after anything touches/updates grub.

Install using:
```
cd .. && dpkg -i linux-headers* linux-image*
sudo grub-install
```

Enjoy!

My current kernel:
```
Linux reeps-sp3 3.19.0-13-generic #14 SMP Fri Apr 10 14:37:38 PDT 2015 x86_64 x86_64 x86_64 GNU/Linux
```
