# -----------------------------------------------------------------------------
#
# Makefile for building native neutrino and libstb-hal
#
# (C) 2012,2013 Stefan Seyfried
# (C) 2015 Sven Hoefer
#
# prerequisite packages need to be installed, no checking is done for that
#
# -----------------------------------------------------------------------------
#
# This is a 'stand-alone' Makefile that works outside of our buildsystem too.
#
# Prerequisits
# ------------
#
# apt-get install build-essential ccache git make subversion patch gcc bison \
# 	flex texinfo automake libtool ncurses-dev pkg-config
#
# Neutrino dependencies for Debian
# --------------------------------
#
# apt-get install libavformat-dev
# apt-get install libswscale-dev
# apt-get install deb-multimedia-keyring
# apt-get install libswresample-dev
# apt-get install libopenthreads-dev
# apt-get install libglew-dev
# apt-get install freeglut3-dev
# apt-get install libao-dev
# apt-get install libid3tag0-dev
# apt-get install libmad0-dev
# apt-get install libcurl4-openssl-dev
# apt-get install libfreetype6-dev
# apt-get install libsigc++-2.0-dev
# apt-get install libreadline6-dev
# apt-get install libjpeg-dev
# apt-get install libgif-dev
# apt-get install libflac-dev
# apt-get install clutter-1.0
# -----------------------------------------------------------------------------

# first target is default...
default: libstb-hal neutrino plugins-lua

# ddt
NEUTRINO = neutrino-ddt
N_BRANCH = master
N_URL = https://github.com/Duckbox-Developers/neutrino-ddt.git
N_PATCHES =
HAL = libstb-hal-ddt
HAL_BRANCH = master
HAL_URL = https://github.com/Duckbox-Developers/libstb-hal-ddt.git
HAL_PATCHES =	

#
BOXMODEL ?= generic

#
SRC = $(PWD)/src
OBJ = $(PWD)/obj
DEST = $(PWD)/$(BOXMODEL)
PATCHES = $(PWD)/patches

HAL_SRC = $(SRC)/$(HAL)
HAL_OBJ = $(OBJ)/$(HAL)
N_SRC = $(SRC)/$(NEUTRINO)
N_OBJ = $(OBJ)/$(NEUTRINO)

PATCH                 = patch -p1 -i $(PATCHES)
APATCH                = patch -p1 -i
define apply_patches
    for i in $(1); do \
        if [ -d $$i ]; then \
            for p in $$i/*; do \
                if [ $${p:0:1} == "/" ]; then \
                    echo -e "==> Applying Patch: $$p"; $(APATCH) $$p; \
                else \
                    echo -e "==> Applying Patch: $$p"; $(PATCH)/$$p; \
                fi; \
            done; \
        else \
            if [ $${i:0:1} == "/" ]; then \
                echo -e "==> Applying Patch: $$i"; $(APATCH) $$i; \
            else \
                echo -e "==> Applying Patch: $$i"; $(PATCH)/$$i; \
            fi; \
        fi; \
    done; \
    echo -e "Patching $(TERM_GREEN_BOLD)$(PKG_NAME) $(PKG_VER)$(TERM_NORMAL) completed"; \
    echo
endef

#
CFLAGS  = -W
CFLAGS += -Wall
#CFLAGS += -Werror
CFLAGS += -Wextra
CFLAGS += -Wshadow
CFLAGS += -Wsign-compare
#CFLAGS += -Wconversion
#CFLAGS += -Wfloat-equal
CFLAGS += -Wuninitialized
CFLAGS += -Wmaybe-uninitialized
CFLAGS += -Werror=type-limits
CFLAGS += -Warray-bounds
CFLAGS += -Wformat-security
#CFLAGS += -fmax-errors=10
CFLAGS += -O0 -g -ggdb3
CFLAGS += -funsigned-char
CFLAGS += -rdynamic
CFLAGS += -DPEDANTIC_VALGRIND_SETUP
CFLAGS += -DDYNAMIC_LUAPOSIX
CFLAGS += -D__KERNEL_STRICT_NAMES
CFLAGS += -D__STDC_FORMAT_MACROS
CFLAGS += -D__STDC_CONSTANT_MACROS
# enable --as-needed for catching more build problems...
CFLAGS += -Wl,--as-needed

# in case some libs are installed in $(DEST) (e.g. dvbsi++)
CFLAGS += -I$(DEST)/include
CFLAGS += -L$(DEST)/lib
CFLAGS += -L$(DEST)/lib64

# workaround for debian's non-std sigc++ locations
CFLAGS += -I/usr/include/sigc++-2.0
CFLAGS += -I/usr/lib/x86_64-linux-gnu/sigc++-2.0/include

PKG_CONFIG_PATH = $(DEST)/lib/pkgconfig
export PKG_CONFIG_PATH

CXXFLAGS  = $(CFLAGS)
CXXFLAGS +=  -std=c++11
export CFLAGS CXXFLAGS

run:
	export SIMULATE_FE=1; \
	$(DEST)/bin/neutrino

run-gdb:
	export SIMULATE_FE=1; \
	gdb -ex run $(DEST)/bin/neutrino

run-valgrind:
	export SIMULATE_FE=1; \
	valgrind --leak-check=full --log-file="$(DEST)/valgrind.log" -v $(DEST)/bin/neutrino

neutrino: $(N_OBJ)/config.status | $(DEST) $(N_SRC)/src/gui/version.h
	-rm $(N_OBJ)/src/neutrino # force relinking on changed libstb-hal
	$(MAKE) -C $(N_OBJ) install

libstb-hal: $(HAL_OBJ)/config.status | $(DEST)
	$(MAKE) -C $(HAL_OBJ) install

$(N_SRC)/src/gui/version.h:
	@rm -f $@; \
	echo '#define BUILT_DATE "'`date`'"' > $@
	@if test -d $(HAL_SRC) ; then \
		pushd $(HAL_SRC) ; \
		HAL_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(N_SRC) ; \
		NMP_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		pushd $(PWD) ; \
		DDT_REV=$$(git log | grep "^commit" | wc -l) ; \
		popd ; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@ ; \
	fi
	
$(N_OBJ)/config.status: | $(N_OBJ) $(N_SRC) libstb-hal
	set -e; cd $(N_SRC); \
		git checkout $(N_BRANCH); \
	$(N_SRC)/autogen.sh
	set -e; cd $(N_OBJ); \
		$(N_SRC)/configure \
			--prefix=$(DEST) \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-mdev \
			--enable-giflib \
			--enable-cleanup \
			--enable-lua \
			--with-target=native \
			--with-boxtype=$(BOXMODEL) \
			--with-stb-hal-includes=$(HAL_SRC)/include \
			--with-stb-hal-build=$(DEST)/lib \
			; \

$(HAL_OBJ)/config.status: | $(HAL_OBJ) $(HAL_SRC)
	set -e; cd $(HAL_SRC); \
		git checkout $(HAL_BRANCH)
	$(HAL_SRC)/autogen.sh
	set -e; cd $(HAL_OBJ); \
		$(HAL_SRC)/configure \
			--prefix=$(DEST) \
			--with-boxtype=$(BOXMODEL) \
			--enable-maintainer-mode \
			--enable-clutter \
			--enable-shared=no

$(OBJ):
	mkdir -p $(OBJ)

$(OBJ)/$(NEUTRINO) \
$(OBJ)/$(HAL): | $(OBJ)
	mkdir -p $@

$(DEST):
	mkdir -p $@

$(SRC):
	mkdir -p $@

$(N_SRC): | $(SRC)
	rm -rf $(N_SRC)
	[ -d "$(N_SRC)" ] && \
	(cd $(N_SRC); git pull;); \
	[ -d "$(N_SRC)" ] || \
	git clone $(N_URL) $(N_SRC); \
	set -e; cd $(N_SRC); \
		$(call apply_patches, $(N_PATCHES))

$(HAL_SRC): | $(SRC)
	rm -rf $(HAL_SRC)
	[ -d "$(HAL_SRC)" ] && \
	(cd $(HAL_SRC); git pull;); \
	[ -d "$(HAL_SRC)" ] || \
	git clone $(HAL_URL) $(HAL_SRC); \
	set -e; cd $(HAL_SRC); \
		$(call apply_patches, $(HAL_PATCHES))

checkout: $(SRC)/$(HAL) $(SRC)/$(NEUTRINO)

update:
	git pull

neutrino-clean:
	-$(MAKE) -C $(N_OBJ) clean

libstb-hal-clean:
	-$(MAKE) -C $(HAL_OBJ) clean

clean: neutrino-clean libstb-hal-clean

neutrino-distclean:
	-$(MAKE) -C $(N_OBJ) distclean

libstb-hal-distclean:
	-$(MAKE) -C $(HAL_OBJ) distclean
	
#
# neutrino-plugins-scripts-lua
#
plugins-lua:
	set -e; 
	[ -d "$(SRC)/neutrino-plugin-scripts-lua" ] && \
	(cd $(SRC)/plugin-scripts-lua; git pull;); \
	[ -d "$(SRC)/plugin-scripts-lua.git" ] || \
	git clone https://github.com/Duckbox-Developers/plugin-scripts-lua.git $(SRC)/plugin-scripts-lua; \
	cd $(SRC)/plugin-scripts-lua; \
		install -d $(DEST)/var/tuxbox/plugins
#		cp -R $(BUILD_TMP)/neutrino-plugin-scripts-lua/favorites2bin/* $(TARGET_DIR)/var/tuxbox/plugins/
		cp -R $(SRC)/plugin-scripts-lua/plugins/ard_mediathek/* $(DEST)/var/tuxbox/plugins/
		cp -R $(SRC)/plugin-scripts-lua/plugins/mtv/* $(DEST)/var/tuxbox/plugins/
		cp -R $(SRC)/plugin-scripts-lua/plugins/netzkino/* $(DEST)/var/tuxbox/plugins/
	
distclean: neutrino-distclean libstb-hal-distclean

# libdvbsi is not commonly packaged for linux distributions...
libdvbsi: | $(DEST)
	rm -rf $(SRC)/libdvbsi++
	git clone https://github.com/OpenVisionE2/libdvbsi.git $(SRC)/libdvbsi++
	set -e; cd $(SRC)/libdvbsi++; \
		./autogen.sh; \
		./configure \
			--prefix=$(DEST) \
			; \
		$(MAKE); \
		make install
	rm -rf $(SRC)/libdvbsi++

LUA_VER=5.2.4
$(SRC)/lua-$(LUA_VER).tar.gz: | $(SRC)
	cd $(SRC) && wget http://www.lua.org/ftp/lua-$(LUA_VER).tar.gz

lua: $(SRC)/lua-$(LUA_VER).tar.gz | $(DEST)
	rm -rf $(SRC)/lua-$(LUA_VER)
	tar -C $(SRC) -xf $(SRC)/lua-$(LUA_VER).tar.gz
	set -e;	cd $(SRC)/lua-$(LUA_VER); \
		sed -i "s|^#define LUA_ROOT	.*|#define LUA_ROOT	\"$(DEST)/\"|" src/luaconf.h && \
		$(MAKE) linux; \
		make install INSTALL_TOP=$(DEST)
	rm -rf $(SRC)/lua-$(LUA_VER)
	rm -rf $(DEST)/man

FFMPEG_VER=4.2
$(SRC)/ffmpeg-$(FFMPEG_VER).tar.bz2: | $(SRC)
	cd $(SRC) && wget http://www.ffmpeg.org/releases/ffmpeg-$(FFMPEG_VER).tar.bz2

ffmpeg: $(SRC)/ffmpeg-$(FFMPEG_VER).tar.bz2 | $(DEST)
	rm -rf $(SRC)/ffmpeg-$(FFMPEG_VER)
	tar -C $(SRC) -xf $(SRC)/ffmpeg-$(FFMPEG_VER).tar.bz2
	set -e; cd $(SRC)/ffmpeg-$(FFMPEG_VER); \
		./configure \
			--prefix=$(DEST) \
			\
			--disable-doc \
			--disable-htmlpages \
			--disable-manpages \
			--disable-podpages \
			--disable-txtpages \
			\
			--disable-stripping \
			; \
		$(MAKE); \
		make install
	rm -rf $(SRC)/ffmpeg-$(FFMPEG_VER)

libs: libdvbsi ffmpeg lua

PHONY  = $(DEST)
PHONY += checkout

.PHONY: $(PHONY)

