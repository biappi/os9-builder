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

C0_DESC		= c0
C0_DESCSRC		= $(CFIDE)/$(C0_DESC).a
C0_DESCMOD		= $(ODIR)/$(C0_DESC)
C0_DESCREL		= $(RDIR)/$(C0_DESC).r
C0_DESCMOD_FMT	= $(ODIR)/$(C0_DESC)_fmt
C0_DESCREL_FMT	= $(RDIR)/$(C0_DESC)_fmt.r

R0_DESC        = r0
R0_DESCSRC     = $(SDIR)/$(R0_DESC).a
R0_DESCMOD     = $(ODIR)/$(R0_DESC)
R0_DESCREL     = $(RDIR)/$(R0_DESC).r
R0_DESCMOD_FMT = $(ODIR)/$(R0_DESC)_fmt
R0_DESCREL_FMT = $(RDIR)/$(R0_DESC)_fmt.r

DD_DESC    = dd
DD_DESCMOD = $(ODIR)/$(DD_DESC)

build: $(RDIR) $(ODIR) $(C0_DESCMOD) $(C0_DESCMOD_FMT) $(R0_DESCMOD) $(R0_DESCMOD_FMT) $(DD_DESCMOD)

$(C0_DESCMOD): $(C0_DESCREL) $(SLIB)
	$(LC) $(LFLAGS) $(C0_DESCREL) -O=$@
	$(TOUCH) $(FLAGFILE)

$(C0_DESCREL): $(C0_DESCSRC) $(SYSDEFS) $(MAKER)
	$(RC) $(RFLAGS) $(C0_DESCSRC) -O=$@

$(C0_DESCMOD_FMT): $(C0_DESCREL_FMT) $(SLIB)
	$(LC) $(LFLAGS) $(C0_DESCREL_FMT) -O=$@
	$(TOUCH) $(FLAGFILE)

$(C0_DESCREL_FMT): $(C0_DESCSRC) $(SYSDEFS) $(MAKER)
	$(RC) $(RFLAGS) -aFMT_ENABLE $(C0_DESCSRC) -O=$@


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


$(DD_DESCMOD): $(R0_DESCREL) $(SLIB)
	$(LC) $(LFLAGS) $(R0_DESCREL) -O=$@ -n=$(DD_DESC)
	$(TOUCH) $(FLAGFILE)

$(ODIR) $(RDIR):
	@$(MD) $@


clean:
	$(RM) $(C0_DESCMOD) $(C0_DESCREL) $(C0_DESCMOD_FMT) $(C0_DESCREL_FMT) $(R0_DESCMOD) $(R0_DESCREL) $(R0_DESCMOD_FMT) $(R0_DESCREL_FMT) $(DD_DESCMOD)
