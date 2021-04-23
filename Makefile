PATCHES :=

MODULES := libzrtp rem re baresip retest

ifeq ($(TARGET),android)
  MODULES := openssl opus ogg $(MODULES)
  PATCHES := patches/re.patch patches/re_flexisip_registration_issue.patch
else
  MODULES := libsrtp $(MODULES)
  PATCHES := /dev/null
  PATCHES := patches/re_flexisip_registration_issue.patch
  # PATCHES := patches/baresip_modules_httpreq_http_conf.patch
endif

TOWIPEALL   := $(patsubst %,%_wipeall,$(MODULES))
TOBUILD     := $(patsubst %,%_build,$(MODULES))
TOUNINSTALL := $(patsubst %,%_uninstall,$(MODULES))

prepare: update $(MODULES)

ifneq ($(findstring android, $(TARGET)),)
  include Makefile.android
else
  include Makefile.unix
endif

update: gitinit gitclean gitupdate

gitinit:
	@git submodule sync
	@git submodule update --init
	@git submodule foreach 'git checkout \
                               $$(                              \
                                  git config                    \
                                      -f $$toplevel/.gitmodules \
                                      submodule.$$name.branch   \
                                  ||                            \
                                  echo master                   \
                               )'

gitupdate:
	@git submodule foreach 'git pull ; true'

gitclean:
	@git submodule foreach 'git clean -xdff ; git checkout -- .; true'

clean:
	@git submodule foreach 'make clean; true'

distclean: clean
	@git submodule foreach 'make distclean; true'

wipeall: $(TOWIPEALL)

baresip re rem retest:
	@echo
	@echo "Fetching $@"
	@echo
	git submodule add https://github.com/baresip/$@.git

libsrtp:
	@echo
	@echo "Fetching $@"
	@echo
	git submodule add https://github.com/cisco/libsrtp.git

libzrtp:
	@echo
	@echo "Fetching $@"
	@echo
	git submodule add https://github.com/juha-h/libzrtp

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
