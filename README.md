# ntfs3 for debian

While the [ntfs3 module][ntfs3] is present in the kernel source tree used by debian,
the module appears to be disabled in the shipped binary kernel packages.

```console
$ grep CONFIG_NTFS3 /boot/config-*
# CONFIG_NTFS3_FS is not set
```

This is a huge bummer, since it leaves us with the *s-l-o-w* [ntfs-3g][ntfs-3g] as
the only option for read/write access to NTFS volumes. Fortunately, [dkms][dkms]
makes it (relatively) easy to compile and use the module yourself.

This repository contains some helpers that further streamline extracting the ntfs3
source for your debian and building it with dkms, giving you access to all the modern
ntfs3 goodness.

The helpers are built around GNU Make.

## Prerequisites

Of course, you will need dkms and a compiler toolchain to compile your module.

```bash
sudo apt-get install build-essential dkms
```

Then, you need to get the **headers and sources for your kernel**. If there is a tag
in this repository that matches your kernel, you can checkout the respective tag from
the repository and skip retrieving (and later updating) the sources.

```bash
# list installed kernel images
dpkg -l | grep linux-image

# install linux headers
sudo apt-get install linux-headers-6.1.0-28-marvell

# retrieve debian source for your running kernel
cd linux && apt-get source linux-image-6.1.0-28-marvell
```

## Updating the source and compiling the module

First, you need to get some version of the ntfs3 module. This is something you
probably want to do, as it is straightforward and has a better chance of success.

```bash
# update ntfs3 module from the kernel sources retrieved (recommended)
make update

# or

# try ntfs3 module from a repository tag
git checkout v6.1.119
```

Them you should be able to compile the module:

```bash
# copy ntfs3 module to /usr/src and use dkms to compile it
make dkms
```

Finally, if everything goes according to plan, then you should be able to load and
use the module.

```bash
sudo modprobe ntfs3
sudo mount /dev/sde1 /media/disk1 -t ntfs3 -o prealloc,nohidden,uid=1000,gid=1000
```

## Troubleshooting

The `dkms build` command may fail if linux headers directory has been "disturbed".
This will result in a message like this in the produced `make.log`.

```console
  ERROR: Kernel configuration is invalid.
         include/generated/autoconf.h or include/config/auto.conf are missing.
         Run 'make oldconfig && make prepare' on kernel src to fix it.
```

This is resolved by reinstalling your linux headers. Reinstalling will also
automatically re-trigger `dkms build` and autoinstall the module.

```bash
sudo apt-get install --reinstall linux-headers-6.1.0-28-marvell
```

## Acknowledgements & motivation

There are already several efforts [^ntfs3-dkms-1][^ntfs3-dkms-2][^ntfs3-dkms-3] that
aim to utilize dkms to bring ntfs3 support to debian. However, trying to use them I
found them constrained to specific versions of the ntfs3 source.

If you are lucky and a specific version works on your system, then good for you! But
chances are it won't, as even "nearby" kernel versions may have incompatibilities.
E.g. source from 6.1.85 (currently used by Debian-ntfs3 [^ntfs3-dkms-1]) appears to
have macros that would not work with 6.1.119 I have on my system.

This prompted me to take it one step further and also make the extraction of the
ntfs3 source from the official debian kernel source tree part of the process. This
means that even if the source code committed in the repository does not work for you,
it should be straightforward to extract a working version.


[ntfs3]: https://docs.kernel.org/filesystems/ntfs3.html
[ntfs-3g]: https://github.com/tuxera/ntfs-3g
[dkms]: https://github.com/dell/dkms
[^ntfs3-dkms-1]: https://github.com/wydy/Debian-ntfs3
[^ntfs3-dkms-2]: https://github.com/EasyNetDev/ntfs3-dkms
[^ntfs3-dkms-3]: https://github.com/rmnscnce/ntfs3
