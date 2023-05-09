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
# apt-get install libgstreamer1.0-dev
# apt-get install libgstreamer-plugins-base1.0-dev
# apt-get install libgstreamer-plugins-bad1.0-dev
# apt-get install clutter-1.0
# -----------------------------------------------------------------------------

# first target is default...
default: neutrino

# init
init:
	@echo "Select neutrino"
	@echo "	1) ddt"
	@echo "	2) tuxbox"
	@echo "	3) max"
	@echo "	4) tangos"
	@echo "	5) ni"
	@read -p "Select neutrino(1-5)?" FLAVOUR; \
	FLAVOUR=$${FLAVOUR}; \
	case "$$FLAVOUR" in \
		1) FLAVOUR="ddt";; \
		2) FLAVOUR="tuxbox";; \
		3) FLAVOUR="max";;\
		4) FLAVOUR="tangos";; \
		5) FLAVOUR="ni";; \
		*) FLAVOUR="ddt";; \
	esac; \
	echo "FLAVOUR=$$FLAVOUR" > config.local
	@echo ""

-include config.local

# tuxbox
ifeq ($(FLAVOUR), tuxbox)
NEUTRINO = gui-neutrino
N_BRANCH = master
N_URL = https://github.com/tuxbox-neutrino/gui-neutrino.git
HAL = library-stb-hal
HAL_BRANCH = mpx
HAL_URL = https://github.com/tuxbox-neutrino/library-stb-hal.git
N_PATCHES =
HAL_PATCHES =	
endif

# ddt
ifeq ($(FLAVOUR), ddt)
NEUTRINO = neutrino-ddt
N_BRANCH = master
N_URL = https://github.com/Duckbox-Developers/neutrino-ddt.git
HAL = libstb-hal-ddt
HAL_BRANCH = master
HAL_URL = https://github.com/Duckbox-Developers/libstb-hal-ddt.git
N_PATCHES = neutrino-ddt.patch
HAL_PATCHES =	
endif

# max
ifeq ($(FLAVOUR), max)
NEUTRINO = neutrino-max
N_BRANCH = master
N_URL = https://github.com/MaxWiesel/neutrino-max.git
HAL = libstb-hal-max
HAL_BRANCH = master
HAL_URL = https://github.com/MaxWiesel/libstb-hal-max.git
N_PATCHES =
HAL_PATCHES =	
endif

# tangos
ifeq ($(FLAVOUR), tangos)
NEUTRINO = neutrino-tangos
N_BRANCH = master
N_URL = https://github.com/TangoCash/neutrino-tangos.git
HAL = libstb-hal-tangos
HAL_BRANCH = master
HAL_URL = https://github.com/TangoCash/libstb-hal-tangos.git
N_PATCHES = neutrino-tangos.patch
HAL_PATCHES =	
endif

# ni
ifeq ($(FLAVOUR), ni)
NEUTRINO = ni-neutrino
N_BRANCH = master
N_URL = https://github.com/neutrino-images/ni-neutrino.git
HAL = ni-libstb-hal
HAL_BRANCH = master
HAL_URL = https://github.com/neutrino-images/ni-libstb-hal.git
N_PATCHES =
HAL_PATCHES =
endif

#
BOXMODEL ?= generic

#
NEUTRINO ?= neutrino-ddt
N_BRANCH ?= master
N_URL ?= https://github.com/Duckbox-Developers/$(NEUTRINO).git
HAL ?= libstb-hal-ddt
HAL_BRANCH ?= master
HAL_URL ?= https://github.com/Duckbox-Developers/$(HAL).git
N_PATCHES ?=
HAL_PATCHES ?=

#
SRC = $(PWD)/src
OBJ = $(PWD)/obj
DEST = $(PWD)/root
PATCHES = $(PWD)/patches
ARCHIVE = $(HOME)/Archive

HAL_SRC = $(SRC)/$(HAL)
HAL_OBJ = $(OBJ)/$(HAL)
N_SRC = $(SRC)/$(NEUTRINO)
N_OBJ = $(OBJ)/$(NEUTRINO)

#
TERM_RED             := \033[00;31m
TERM_RED_BOLD        := \033[01;31m
TERM_GREEN           := \033[00;32m
TERM_GREEN_BOLD      := \033[01;32m
TERM_YELLOW          := \033[00;33m
TERM_YELLOW_BOLD     := \033[01;33m
TERM_NORMAL          := \033[0m

#
PATCH                 = patch -p1 -i $(PATCHES)
APATCH                = patch -p1 -i
define apply_patches
    for i in $(1); do \
        if [ -d $$i ]; then \
            for p in $$i/*; do \
                if [ $${p:0:1} == "/" ]; then \
                    echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$p"; $(APATCH) $$p; \
                else \
                    echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$p"; $(PATCH)/$$p; \
                fi; \
            done; \
        else \
            if [ $${i:0:1} == "/" ]; then \
                echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$i"; $(APATCH) $$i; \
            else \
                echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$i"; $(PATCH)/$$i; \
            fi; \
        fi; \
    done; \
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
#CFLAGS += -DASSUME_MDEV
#CFLAGS += -DTEST_MENU
# enable --as-needed for catching more build problems...
CFLAGS += -Wl,--as-needed

# in case some libs are installed in $(DEST) (e.g. dvbsi++)
CFLAGS += -I$(DEST)/include
CFLAGS += -L$(DEST)/lib
CFLAGS += -L$(DEST)/lib64

# workaround for debian's non-std sigc++ locations
CFLAGS += -I/usr/include/sigc++-2.0
CFLAGS += -I/usr/lib/x86_64-linux-gnu/sigc++-2.0/include

# gstreamer flags
CFLAGS += -DENABLE_GSTREAMER_10
CFLAGS += $(shell pkg-config --cflags --libs gstreamer-1.0)
CFLAGS += $(shell pkg-config --cflags --libs gstreamer-audio-1.0)
CFLAGS += $(shell pkg-config --cflags --libs gstreamer-video-1.0)

PKG_CONFIG_PATH = $(DEST)/lib/pkgconfig
export PKG_CONFIG_PATH

CXXFLAGS  = $(CFLAGS)
CXXFLAGS +=  -std=c++11
export CFLAGS CXXFLAGS

# -----------------------------------------------------------------------------
run:
	export SIMULATE_FE=1; \
	$(DEST)/bin/neutrino

run-gdb:
	export SIMULATE_FE=1; \
	gdb -ex run $(DEST)/bin/neutrino

run-valgrind:
	export SIMULATE_FE=1; \
	valgrind --leak-check=full --log-file="$(DEST)/valgrind.log" -v $(DEST)/bin/neutrino

# -----------------------------------------------------------------------------

neutrino: $(N_OBJ)/config.status | $(DEST)
	-rm $(N_OBJ)/src/neutrino # force relinking on changed libstb-hal
	$(MAKE) -C $(N_OBJ) install

libstb-hal: $(HAL_OBJ)/config.status | $(DEST)
	$(MAKE) -C $(HAL_OBJ) install

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
			--with-target=native \
			--with-boxtype=generic \
			$(if $(filter $(BOXMODEL), raspi),--with-boxmodel=raspi) \
			$(if $(filter $(FLAVOUR), tangos),--disable-pip) \
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
			--with-target=native \
			--with-boxtype=generic \
			$(if $(filter $(BOXMODEL), raspi),--with-boxmodel=raspi) \
			--enable-maintainer-mode \
			--enable-shared=no \
			$(if $(filter $(FLAVOUR), ddt),--enable-gstreamer_10=yes) \
			;

# -----------------------------------------------------------------------------

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
	[ -d "$(ARCHIVE)/$(NEUTRINO).git" ] && \
	(cd $(ARCHIVE)/$(NEUTRINO).git; git pull; cd "$(SRC)";); \
	[ -d "$(ARCHIVE)/$(NEUTRINO).git" ] || \
	git clone $(N_URL) $(ARCHIVE)/$(NEUTRINO).git; \
	cp -ra $(ARCHIVE)/$(NEUTRINO).git $(SRC)/$(NEUTRINO);
	set -e; cd $(N_SRC); \
		$(call apply_patches, $(N_PATCHES)) 

$(HAL_SRC): | $(SRC)
	rm -rf $(HAL_SRC)
	[ -d "$(ARCHIVE)/$(HAL).git" ] && \
	(cd $(ARCHIVE)/$(HAL).git; git pull; cd "$(SRC)";); \
	[ -d "$(ARCHIVE)/$(HAL).git" ] || \
	git clone $(HAL_URL) $(ARCHIVE)/$(HAL).git; \
	cp -ra $(ARCHIVE)/$(HAL).git $(SRC)/$(HAL);
	set -e; cd $(HAL_SRC); \
		$(call apply_patches, $(HAL_PATCHES)) 

# -----------------------------------------------------------------------------

checkout: $(SRC)/$(HAL) $(SRC)/$(NEUTRINO)

update: $(HAL_SRC) $(N_SRC)
	git pull

neutrino-clean:
	-$(MAKE) -C $(N_OBJ) clean
	rm -rf $(N_OBJ)

libstb-hal-clean:
	-$(MAKE) -C $(HAL_OBJ) clean
	rm -rf $(HAL_OBJ)

clean: neutrino-clean libstb-hal-clean

neutrino-distclean:
	rm -rf $(N_OBJ)
	rm -rf $(N_SRC)

libstb-hal-distclean:
	rm -rf $(HAL_OBJ)
	rm -rf $(HAL_SRC)
	
distclean: neutrino-distclean libstb-hal-distclean

# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------

PHONY  = $(DEST)
PHONY += checkout

.PHONY: $(PHONY)
