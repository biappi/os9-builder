#############################################################################
# RBF descriptor modules
#############################################################################

# disable implicit rules as we call the assembler and linker directly
-bo

SDIR		= $(SRCROOT)/IO/RBF/DESC	# RBF descriptor sources
ODIR		= ../CMDS/BOOTOBJS
RDIR		= ./RELS
MAKER		= $(CFIDE)/cfide_descriptors.make	# this file
FLAGFILE	= $(ODIR)/.updated
SYSDEFS		= ../systype.d
RFLAGS		= -q -u=. -u=$(OSDEFS) -u=$(SDIR)
SLIB		= $(SYSRELS)/sys.l
LFLAGS		= -l=$(SLIB) -gu=0.0

DESC		= c0
DESCSRC		= $(CFIDE)/$(DESC).a
DESCMOD		= $(ODIR)/$(DESC)
DESCREL		= $(RDIR)/$(DESC).r
DESCMOD_FMT	= $(ODIR)/$(DESC)_fmt
DESCREL_FMT	= $(RDIR)/$(DESC)_fmt.r

R0_DESC        = r0
R0_DESCSRC     = $(SDIR)/$(R0_DESC).a
R0_DESCMOD     = $(ODIR)/$(R0_DESC)
R0_DESCREL     = $(RDIR)/$(R0_DESC).r
R0_DESCMOD_FMT = $(ODIR)/$(R0_DESC)_fmt
R0_DESCREL_FMT = $(RDIR)/$(R0_DESC)_fmt.r

DDMOD          = $(ODIR)/dd

build: $(RDIR) $(ODIR) $(DESCMOD) $(DESCMOD_FMT) $(R0_DESCMOD) $(R0_DESCMOD_FMT) $(DDMOD)

$(DESCMOD): $(DESCREL) $(SLIB)
	$(LC) $(LFLAGS) $(DESCREL) -O=$@
	$(TOUCH) $(FLAGFILE)

$(DESCREL): $(DESCSRC) $(SYSDEFS) $(MAKER)
	$(RC) $(RFLAGS) $(DESCSRC) -O=$@

$(DESCMOD_FMT): $(DESCREL_FMT) $(SLIB)
	$(LC) $(LFLAGS) $(DESCREL_FMT) -O=$@
	$(TOUCH) $(FLAGFILE)

$(DESCREL_FMT): $(DESCSRC) $(SYSDEFS) $(MAKER)
	$(RC) $(RFLAGS) -aFMT_ENABLE $(DESCSRC) -O=$@


$(R0_DESCMOD): $(R0_DESCREL) $(SLIB)
	$(LC) $(LFLAGS) $(R0_DESCREL) -O=$@
	$(TOUCH) $(FLAGFILE)

$(R0_DESCREL): $(R0_DESCSRC) $(SYSDEFS) $(MAKER)
	$(RC) $(RFLAGS) $(R0_DESCSRC) -O=$@

$(R0_DESCMOD_FMT): $(R0_DESCREL_FMT) $(SLIB)
	$(LC) $(LFLAGS) $(R0_DESCREL_FMT) -O=$@
	$(TOUCH) $(FLAGFILE)

$(R0_DESCREL_FMT): $(R0_DESCSRC) $(SYSDEFS) $(MAKER)
	$(RC) $(RFLAGS) -aFMT_ENABLE $(R0_DESCSRC) -O=$@


$(DDMOD): $(DESCREL) $(SLIB)
	$(LC) $(LFLAGS) $(R0_DESCREL) -O=$@ -n=dd
	$(TOUCH) $(FLAGFILE)

$(ODIR) $(RDIR):
	@$(MD) $@


clean:
	$(RM) $(DESCMOD) $(DESCREL) $(DESCMOD_FMT) $(DESCREL_FMT) $(DDMOD)
