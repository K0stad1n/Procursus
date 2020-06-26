ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += lolcat
LOLCAT_VERSION := 1.0
DEB_LOLCAT_V   ?= $(LOLCAT_VERSION)

lolcat-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/jaseg/lolcat/archive/v$(LOLCAT_VERSION).tar.gz
	$(call EXTRACT_TAR,v$(LOLCAT_VERSION).tar.gz,lolcat-$(LOLCAT_VERSION),lolcat)
	mkdir -p $(BUILD_STAGE)/lolcat/usr/bin

ifneq ($(wildcard $(BUILD_WORK)/lolcat/.build_complete),)
lolcat:
	@echo "Using previously built lolcat."
else
lolcat: lolcat-setup 
	+$(MAKE) -C $(BUILD_WORK)/lolcat
	+$(MAKE) -C $(BUILD_WORK)/lolcat install \
		DESTDIR=$(BUILD_STAGE)/lolcat/usr/bin
	touch $(BUILD_WORK)/lolcat/.build_complete
endif

lolcat-package: lolcat-stage
	# rsync.mk Package Structure
	rm -rf $(BUILD_DIST)/lolcat
	mkdir -p $(BUILD_DIST)/lolcat
	
	# rsync.mk Prep rsync
	cp -a $(BUILD_STAGE)/lolcat/usr $(BUILD_DIST)/lolcat
	
	# rsync.mk Sign
	$(call SIGN,lolcat,general.xml)
	
	# rsync.mk Make .debs
	$(call PACK,lolcat,DEB_LOLCAT_V)
	
	# rsync.mk Build cleanup
	rm -rf $(BUILD_DIST)/lolcat

.PHONY: lolcat lolcat-package
