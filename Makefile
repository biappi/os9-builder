include Makefile.conf

NUM_JOBS := $(shell sysctl -n hw.ncpu)

CB030 := os9-m68k-ports/ports/CB030/
BUILT_ROMIMAGE := $(CB030)/CMDS/BOOTOBJS/ROMBUG/romimage.dev

MAME_ROMS := mame/roms/fake68
MAME_ROMIMAGE := $(MAME_ROMS)/romimage.dev.patched-debugger

MAME_TARGET_OPTS := SUBTARGET=fake68 SOURCES=uilli/fake68.cpp
MAME_OPTS := SYMBOLS=1 VERBOSE=1 REGENIE=1
MAME_OPTS += -j$(NUM_JOBS)

MAME_LDFLAGS := -framework CoreHaptics -liconv -framework GameController -framework ForceFeedback -framework Carbon

ifeq ($(MAME_BUILD_SDL),1)
MAME_CONF_OPTS += USE_LIBSDL=1
ifneq ($(strip $(SDL_PATH)),)
MAME_CFLAGS += -I$(SDL_PATH)/include
MAME_LDFLAGS += $(SDL_PATH)/lib/libSDL2.a
endif
endif

ifeq ($(MAME_BUILD_QT_DEBUGGER),1)
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


$(BUILT_ROMIMAGE):
	cd $(CB030); ../make.sh

$(MAME_ROMIMAGE): $(BUILT_ROMIMAGE)
	mkdir -p $(MAME_ROMS)
	cp $(BUILT_ROMIMAGE) $(MAME_ROMIMAGE)

.PHONY: romimage
romimage:
	cd $(CB030); ../make.sh clean
	cd $(CB030); ../make.sh
	mkdir -p $(MAME_ROMS)
	cp $(BUILT_ROMIMAGE) $(MAME_ROMIMAGE)

.PHONY: mame
mame: $(MAME_ROMIMAGE)
	cd mame; make $(MAME_ALL_OPTS)

.PHONY: run
run: $(MAME_ROMIMAGE)
	cd mame; ./fake68 fake68 -window -debug $(DEBUGGER) -harddisk cfcard.hd

.PHONY: run-term
run-term: $(MAME_ROMIMAGE)
	cd mame; ./fake68 fake68 -window -debug $(DEBUGGER) -harddisk cfcard.hd -rs232_a null_modem -bitb socket.localhost:6969

.PHONY: listen-term
listen-term:
	while true; do stty raw -echo; nc -l 6969; done

.PHONY: make-cfcard
make-cfcard:
	dd if=/dev/zero of=mame/cfcard.hd bs=1m count=5

