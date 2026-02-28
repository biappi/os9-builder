include Makefile.conf

NUM_JOBS := $(shell ./portable_nproc.sh)

MAME_TARGET_OPTS := SUBTARGET=aesthedes2 SOURCES=claessens/aesthedes2.cpp
MAME_OPTS := SYMBOLS=1 VERBOSE=1 REGENIE=1
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

.PHONY: mame
mame: 
	cd mame; make $(MAME_ALL_OPTS)

.PHONY: run
run: 
	cd mame; ./aesthedes2 aesthedes2 -window -console -debug $(MAME_DEBUGGER)
