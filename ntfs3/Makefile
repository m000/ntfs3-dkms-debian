# SPDX-License-Identifier: GPL-2.0
#
# Makefile for the ntfs3 filesystem support.
#

# to check robot warnings
ccflags-y += -Wint-to-pointer-cast \
	$(call cc-option,-Wunused-but-set-variable,-Wunused-const-variable) \
	$(call cc-option,-Wold-style-declaration,-Wout-of-line-declaration)

obj-$(CONFIG_NTFS3_FS) += ntfs3.o

ntfs3-y :=	attrib.o \
		attrlist.o \
		bitfunc.o \
		bitmap.o \
		dir.o \
		fsntfs.o \
		frecord.o \
		file.o \
		fslog.o \
		inode.o \
		index.o \
		lznt.o \
		namei.o \
		record.o \
		run.o \
		super.o \
		upcase.o \
		xattr.o

ntfs3-$(CONFIG_NTFS3_LZX_XPRESS) += $(addprefix lib/,\
		decompress_common.o \
		lzx_decompress.o \
		xpress_decompress.o \
		)

# Supplementary Makefile rules for building ntfs3 with dkms.
PWDX=$(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
KVERSION?=$(shell uname -r)

all:
	make -C /lib/modules/$(KVERSION)/build M=$(PWDX) modules

clean:
	make -C /lib/modules/$(KVERSION)/build M=$(PWDX) clean
