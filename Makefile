include Makefile.conf

NUM_JOBS := $(shell ./portable_nproc.sh)

#MFR := uilli
#NAME := another

MFR := claessens
NAME := aesthedes2


MAME_TARGET_OPTS := SUBTARGET=$(NAME) SOURCES=$(MFR)/$(NAME).cpp
MAME_OPTS := VERBOSE=1
MAME_OPTS += -j$(NUM_JOBS)

MAME_LDFLAGS_MACOS := -framework CoreHaptics -liconv -framework GameController -framework ForceFeedback -framework Carbon

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
MAME_LDFLAGS := $(MAME_LDFLAGS_MACOS)
else
MAME_LDFLAGS :=
endif

ifeq ($(MAME_BUILD_SDL),1)
MAME_CONF_OPTS += USE_LIBSDL=1
endif

ifeq ($(MAME_BUILD_QT_DEBUGGER),1)
MAME_CONF_OPTS += USE_QTDEBUG=1
MAME_DEBUGGER := -debugger qt
PATH := $(QT_PATH)/bin:$(QT_PATH)/libexec:$(PATH)
MAME_LDFLAGS += -rpath $(QT_PATH)/lib
else
MAME_DEBUGGER := -debugger auto
endif

MAME_ALL_OPTS += CFLAGS="$(MAME_CFLAGS)"
MAME_ALL_OPTS += LDFLAGS="$(MAME_LDFLAGS)"
MAME_ALL_OPTS += $(MAME_TARGET_OPTS)
MAME_ALL_OPTS += $(MAME_CONF_OPTS)
MAME_ALL_OPTS += $(MAME_OPTS)

HDIMAGES_DIR = mame/roms/$(NAME)

.PHONY: mame
mame: 
	cd mame; make $(MAME_ALL_OPTS)

.PHONY: run
run: 
	cd mame; ./$(NAME) $(NAME) -window -console -debug $(MAME_DEBUGGER) -oslog -log -rewind -harddisk ../$(HDIMAGES_DIR)/harddisk_504.bin

run-emu:
	echo "#!/bin/sh" > $@
	echo "set -e" >> $@
	echo "cd mame" >> $@
	echo "./$(NAME) $(NAME) -window -console -debug $(MAME_DEBUGGER) -oslog -log -rewind -harddisk ../$(HDIMAGES_DIR)/harddisk_504.bin \"\$$@\" 2>&1 | tee ../mame.log" >> $@

	chmod +x $@
