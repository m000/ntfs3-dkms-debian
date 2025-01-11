# Supplementary Makefile rules for building ntfs3 with dkms.
PWDX=$(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
KVERSION?=$(shell uname -r)

all:
	make -C /lib/modules/$(KVERSION)/build M=$(PWDX) modules

clean:
	make -C /lib/modules/$(KVERSION)/build M=$(PWDX) clean
