include Makefile.conf

NUM_JOBS := $(shell sysctl -n hw.ncpu)

CB030 := os9-m68k-ports/ports/CB030/
APPS := os9-m68k-ports/apps
APPS_BINS += $(APPS)/bin/hello
APPS_BINS += $(APPS)/bin/AE_CONFIG
BUILT_ROMIMAGE := $(CB030)/CMDS/BOOTOBJS/ROMBUG/romimage.dev

MAME_ROMS := mame/roms/fake68
MAME_ROMIMAGE := $(MAME_ROMS)/romimage.dev.patched-debugger

MAME_TARGET_OPTS := SUBTARGET=fake68 SOURCES=uilli/fake68.cpp
MAME_OPTS := SYMBOLS=1 VERBOSE=1 REGENIE=1
MAME_OPTS += -j$(NUM_JOBS)

MAME_LDFLAGS := -framework CoreHaptics -liconv -framework GameController -framework ForceFeedback -framework Carbon

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

$(APPS_BINS):
	cd $(APPS)/src/hello_c; ../make.sh
	cd $(APPS)/src/AE_CONFIG; ../make.sh

.PHONY: apps
apps: $(APPS_BINS)


.PHONY: $(BUILT_ROMIMAGE)
$(BUILT_ROMIMAGE):
	cd $(CB030); ../make.sh clean
	cd $(CB030); ../make.sh

$(MAME_ROMIMAGE): $(BUILT_ROMIMAGE)
	mkdir -p $(MAME_ROMS)
	cp $(BUILT_ROMIMAGE) $(MAME_ROMIMAGE)

.PHONY: romimage
romimage: $(BUILT_ROMIMAGE) $(MAME_ROMIMAGE)

.PHONY: mame
mame: $(MAME_ROMIMAGE)
	cd mame; make $(MAME_ALL_OPTS)

.PHONY: run
run: $(MAME_ROMIMAGE)
	cd mame; ./fake68 fake68 -window -console -debug $(MAME_DEBUGGER) -harddisk cfcard.hd

.PHONY: run-term
run-term:
	cd mame; ./fake68 fake68 -window -console -log -oslog -debug $(MAME_DEBUGGER) -harddisk cfcard.hd -rs232_a null_modem -bitb socket.localhost:6969

.PHONY: listen-term
listen-term:
	while true; do stty raw -echo; nc -l 6969; done

.PHONY: make-cfcard
make-cfcard:
	dd if=/dev/zero of=mame/cfcard.hd bs=1m count=5

