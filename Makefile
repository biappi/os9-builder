CB030 := os9-m68k-ports/ports/CB030/
BUILT_ROMIMAGE := $(CB030)/CMDS/BOOTOBJS/ROMBUG/romimage.dev

MAME_ROMS := mame/roms/fake68
MAME_ROMIMAGE := $(MAME_ROMS)/romimage.dev.patched-debugger

MAME_TARGET_OPTS := SUBTARGET=fake68 SOURCES=uilli/fake68.cpp
MAME_CONF_OPTS := USE_LIBSDL=1 USE_QTDEBUG=1 
MAME_OPTS := SYMBOLS=1 VERBOSE=1 REGENIE=1 -j16
MAME_ALL_OPTS := $(MAME_TARGET_OPTS) $(MAME_CONF_OPTS) $(MAME_OPTS)

DEBUGGER :=

include Makefile.conf

$(BUILT_ROMIMAGE):
	cd $(CB030); ../make.sh

$(MAME_ROMIMAGE):
	mkdir -p $(MAME_ROMS)
	cp $(BUILT_ROMIMAGE) $(MAME_ROMIMAGE)

.PHONY: mame
mame: $(MAME_ROMIMAGE)
	cd mame; make $(MAME_ALL_OPTS)

.PHONY: run
run: $(MAME_ROMIMAGE)
	cd mame; ./fake68 fake68 -window -debug $(DEBUGGER)
