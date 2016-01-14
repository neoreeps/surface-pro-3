# Surface Pro 3
This is a work in progress and will be obsolete at some point when all changes make it upstream.

I have not disabled TPM or SecureBoot.  I have both enabled and have them enabled during install, reboot, etc.  No need any longer to disable them, if using Ubuntu 15.04 which has support for secure boot and key management.

!!!Disclaimer!!!
I do not dual boot.  I used to about 15 years ago back in 2000ish but found I always booted into one OS or the other and rarely if ever booted into both on the same day.  So, I no longer dual boot.  I am currently running Ubuntu Gnome 15.04 CD and erased everything on the disk and performed a fresh installation.  With VMware, VirtualBox, KVM, etc, I find no reason to dual boot any longer, just run your Windows/OSX apps in a VM.  Thus, I cannot help with dual boot issues.

Most of this work is not my own, rather it is a collection of patches and instructions to simplify running Linux on Surface Pro 3.

## Install Caveats
Some users have experienced issues with installing 15.10 directly on SP4. (Maybe other hardware as well?)  Instead, simply install 15.04 and then upgrade to 15.10 using do-release-upgrade:
```
sudo do-release-upgrade
```

## Binary pre-built debs
As I build new kernels, I'll place them in [Google Drive](https://drive.google.com/open?id=0BzNI3Zdy9Y6kfklBazc5Y3VQXzd6MU1oaUFMS0NxWEI4dmpFRmFITWZFZWpfM0U1dUJJaTQ)

# Ubuntu (15.10) - Kernel can be used on 15.04 also
I have just switched to Ubuntu 15.10, and everything seems to be working well.  I am using the 4.3 kernel below with the patches which gives us multi-touch support and ubuntu equivelant kernel.

## 4.3.0 Kernel
Everything seems to be working well. No complaints so far, except power management.

## 4.2.0 Kernel

I found that many of the SP3 features were enabled with no patches.  In fact, the only thing missing was the camera and buttons.  I've included a patch 'wily_surface.patch' to add these features to the wily kernel for use with vivid and wily which also enables the touchpad as a touchpad instead of pointer on multiple devices.

- So far everything works, except power management 
- WiFi is rock solid
- Added new patch which enables touchpad!
- Patch has added support for SP4 typecover and Surface Book
  - Camera PIDs added and keyboard PIDs

NOTE: I don't have an SP4 or Surface Book so I don't know what's functional

### What doesn't work
* power management - suspend still b0rk ... it's inconsistent for me ...

# Build it from scratch

Install all the deps:
```
sudo apt-get install git build-essential kernel-package fakeroot libncurses5-dev libssl-dev ccache
```

## The easy way ...
Just clone this repo and run the build_linux script:
```
USAGE: ./build_linux.sh [clone|pull] [debug|release]
    Actions:
        clone   - remove old build directory and clone fresh, applying all
                  patches and staying at v4.3
		pull    - keep existing build dir and pull changes only, and will 
				  sync all changes from Torvalds current tree
	Options:
		debug   - create debug .deb also (>400MB)
		release - create release build only
																		
	Example: (clone and build release)
	./build_linux.sh clone release
```

## Get the kernel (mainline)
From [Ubuntu GitKernelBuild](https://wiki.ubuntu.com/KernelTeam/GitKernelBuild)

Get the latest source from Linus git tree:
```
git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
```

Apply the patches above which came from [Ubuntu Kernel-PPA](http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.3-rc7-unstable/)
These patches will bring the kernel inline with ubuntu tree.  I found that pulling from kernel.org is 100x faster than the ubuntu git repos.

NOTE: i915 patch from http://lists.freedesktop.org/archives/intel-gfx/2015-October/078622.html

```
patch -p1 --ignore-whitespace -i name.patch
```

After applying all 5 patches, make the config and build:
```
yes '' | make oldconfig
sed -i 's/# CONFIG_SURFACE_PRO3_BUTTON is not set/CONFIG_SURFACE_PRO3_BUTTON=m/g' .config
make clean
make -j `getconf _NPROCESSORS_ONLN` deb-pkg LOCALVERSION=-reeps
```

## Get the kernel (ubuntu)
From [Ubuntu Kernel Git Guide](https://wiki.ubuntu.com/Kernel/Dev/KernelGitGuide?action=show&redirect=KernelTeam%2FKernelGitGuide)

```
sudo apt-get install git
mkdir ~/source && cd ~/source
git clone git://kernel.ubuntu.com/ubuntu/ubuntu-vivid.git
 or
git clone git://kernel.ubuntu.com/ubuntu/ubuntu-wily.git
```

### Apply the patches and Build
Copy or download the above patch and apply with:
```
patch -p1 --ignore-whitespace -i wily_surface.patch
```

For the 3.19 kernels apply all 4 patches from the archive folder, for the 4.2.0 kernel just apply the wily_surface.patch file.

Before building the kernel, I update the version number to avoid software update from constantly overwriting (or attempting to) my kernel.  Simply edit debian.master/changelog and increment the version number by 1.
```
example: 4.2.0-11.13 -> 4.2.0-11.14
```

Build your new kernel with:
```
fakeroot debian/rules clean
DEB_BUILD_OPTIONS=parallel=4 AUTOBUILD=1 fakeroot debian/rules binary-headers binary-generic
```

## Install the kernel
**I have found that sometimes after touching grub, the first boot may take a few minutes.  DO NOT STOP IT, let the system boot.  Afterwards, should be fast again.**
Also, always remember to run grub-install after anything touches/updates grub.

Install using:
```
cd .. && dpkg -i linux-headers* linux-image*
sudo grub-install
```

## Recover from grub prompt or UEFI loop
If you find yourself in a loop where the SP3 continues to enter UEFI, do not fret, simply insert your ubuntu 15.04 install USB.

If your system will not boot beyond grub, no worries, do this at the grub prompt:
```
"press 'c' to enter command line"
grub> set root=(hd1,2)
grub> linux /vmlinuz root=/dev/sda2
grub> initrd /initrd.img
grub> boot
```

Enjoy!

My current kernel:
```
Linux REEPS-SP3 4.3.0-reeps #1 SMP Wed Nov 4 19:08:00 PST 2015 x86_64 x86_64 x86_64 GNU/Linux
```
