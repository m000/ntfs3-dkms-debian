# tools
RSYNC=rsync -avh --no-owner --no-group
RSYNCD=$(RSYNC) --delete-after
SRSYNC=sudo $(RSYNC)
SRSYNCD=sudo $(RSYNCD)
SDKMS=sudo dkms -m ntfs3 -v $(call ntfs3_version_dkms)
SED=sed

# options and variables
LINUX_SOURCE=./linux
NTFS3_DKMS=./ntfs3
NTFS3_CONFIG=CONFIG_NTFS3_FS=m CONFIG_NTFS3_LZX_XPRESS=y CONFIG_NTFS3_FS_POSIX_ACL=y CONFIG_NTFS3_64BIT_CLUSTER=n

# functions
define linux_source_match
$(patsubst %/,%,$(lastword $(wildcard $(LINUX_SOURCE)/linux-$(1)*/)))
endef

define ntfs3_from
$(call linux_source_match,$(1))/fs/ntfs3
endef

define ntfs3_version_from
$(lastword $(subst -, ,$(notdir $(call linux_source_match,$(1)))))
endef

define ntfs3_version_dkms
$(shell cat $(NTFS3_DKMS)/.version)
endef

# recipes and targets
.PHONY: all update-% sync-src-% dkms dkms-clean dkms-%

all: help

update: update-6		##- update module source

update-%: sync-src-%	##- update module source by matching % as version
	$(SED) 's/__NTFS3_VERSION__/$(call ntfs3_version_from,$(*))/g; s/__NTFS3_CONFIG__/$(NTFS3_CONFIG)/g' dkms.conf.tpl > $(NTFS3_DKMS)/dkms.conf
	echo '$(call ntfs3_version_from,$(*))' > $(NTFS3_DKMS)/.version
	echo "\n" >> $(NTFS3_DKMS)/Makefile
	cat dkms.mk >> $(NTFS3_DKMS)/Makefile

sync-src-%:
	$(RSYNCD) $(call ntfs3_from,$(*))/ $(NTFS3_DKMS)/

dkms:		##- build and install module
	[ -d /usr/src/ ]
	$(SRSYNCD) $(NTFS3_DKMS)/ /usr/src/ntfs3-$(call ntfs3_version_dkms)/
	$(SDKMS) add
	$(SDKMS) build
	$(SDKMS) install

dkms-clean:	##- uninstall and remove modulue files
	$(SDKMS) uninstall || true
	$(SDKMS) unbuild || true
	$(SDKMS) remove || true
	sudo rm -rf /src/ntfs3-$(call ntfs3_version_dkms)/

dkms-%:		##- run % dkms command for the module
	$(SDKMS) $(*)

help:		##- show this help
	@$(SED) -e '/#\{2\}-/!d; s/\\$$//; s/:[^#\t]*/:\t/; s/#\{2\}- *//' $(MAKEFILE_LIST)
