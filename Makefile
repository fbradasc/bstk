PATCHES :=

# List of modules configured and built with cmake
#
CMAKE_MODULES := re

BUILD_MODULES := openssl

# List of modules configured and built with make
#
GMAKE_MODULES += libzrtp

ifeq ($(TARGET),android)
  GMAKE_MODULES += openssl
  CMAKE_MODULES += opus
  CMAKE_MODULES += ogg
  PATCHES := patches/re.patch
else
  CMAKE_MODULES += libsrtp
  PATCHES := patches/libzrtp_install_prefix.patch
  PATCHES += patches/re_avoid_cmake_config.patch
  # PATCHES += patches/baresip_modules_httpreq_http_conf.patch
endif

# PATCHES += patches/re_flexisip_registration_issue.patch

CMAKE_MODULES += baresip
# CMAKE_MODULES += baresip-apps
# CMAKE_MODULES += retest

GMAKE_CONFIG  := $(patsubst %,%/Makefile,$(GMAKE_MODULES))
BUILD_CONFIG  := $(patsubst %,%/Makefile,$(BUILD_MODULES))
CMAKE_CONFIG  := $(patsubst %,%_config  ,$(CMAKE_MODULES))
TOBUILD_GMAKE := $(patsubst %,%_gmake   ,$(GMAKE_MODULES))
TOBUILD_CMAKE := $(patsubst %,%_cmake   ,$(CMAKE_MODULES))
TOBUILD_BUILD := $(patsubst %,%_build   ,$(BUILD_MODULES))

MODULES   := $(BUILD_MODULES) $(GMAKE_MODULES) $(CMAKE_MODULES)

TOWIPEALL := $(patsubst %,%_wipeall,$(MODULES))

ifneq ($(findstring android, $(TARGET)),)
  include Makefile.android
else
  include Makefile.unix
endif

prepare: update $(MODULES)
# prepare: $(MODULES)

update:
	@echo "Pulling..."
	@git pull --all
	@echo "Syncing..."
	@git submodule sync
	@echo "Updating..."
	@git submodule update --init --force
	@echo "Updating submodules..."
	@git submodule foreach 'git checkout \
                               $$(                              \
                                  git config                    \
                                      -f $$toplevel/.gitmodules \
                                      submodule.$$name.branch   \
                                  ||                            \
                                  echo master                   \
                               )'
	@echo "Pulling submodules..."
	@git submodule foreach 'git pull --all; true'

clean:
	@git submodule foreach 'make clean; true'

distclean: clean
	@git submodule foreach 'make distclean; true'

wipeall: $(TOWIPEALL)

baresip re retest baresip-apps:
	@echo
	@echo "Fetching $@"
	@echo
	git submodule add https://github.com/baresip/$@.git

libsrtp:
	@echo
	@echo "Fetching $@"
	@echo
	git submodule add https://github.com/cisco/$@.git

libzrtp:
	@echo
	@echo "Fetching $@"
	@echo
	git submodule add https://github.com/juha-h/$@

openssl:
	@echo
	@echo "Fetching $@"
	@echo
	git submodule add https://github.com/openssl/$@.git

opus ogg:
	@echo
	@echo "Fetching $@"
	@echo
	git submodule add https://github.com/xiph/$@.git

$(TOWIPEALL):
	@echo
	@echo "Wiping all $@"
	@echo
	rm -rf $(@:_wipeall=)

patch:
	@echo
	@echo "Patching $(PATCHES)"
	@echo
	-for patch in $(PATCHES); \
	do \
		echo ; \
		echo "Patching $$patch" ; \
		echo ; \
		patch -p1 -N < $$patch ; \
	done
