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

R0_DESC			= r0
R0_DESCSRC		= $(SDIR)/$(R0_DESC).a
R0_DESCMOD		= $(ODIR)/$(R0_DESC)
R0_DESCREL		= $(RDIR)/$(R0_DESC).r
R0_DESCMOD_FMT	= $(ODIR)/$(R0_DESC)_fmt
R0_DESCREL_FMT	= $(RDIR)/$(R0_DESC)_fmt.r

C0_DESC	    	= c0
C0_DESCMOD		= $(ODIR)/$(C0_DESC)

H0_DESC	    	= h0
H0_DESCMOD		= $(ODIR)/$(H0_DESC)

DD_DESC    = dd
DD_DESCMOD = $(ODIR)/$(DD_DESC)

build: $(RDIR) $(ODIR) $(R0_DESCMOD) $(R0_DESCMOD_FMT) $(C0_DESCMOD) $(H0_DESCMOD) $(DD_DESCMOD)

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

$(C0_DESCMOD): $(R0_DESCREL) $(SLIB)
	$(LC) $(LFLAGS) $(R0_DESCREL) -O=$@ -n=$(C0_DESC)
	$(TOUCH) $(FLAGFILE)

$(H0_DESCMOD): $(R0_DESCREL) $(SLIB)
	$(LC) $(LFLAGS) $(R0_DESCREL) -O=$@ -n=$(H0_DESC)
	$(TOUCH) $(FLAGFILE)

$(DD_DESCMOD): $(R0_DESCREL) $(SLIB)
	$(LC) $(LFLAGS) $(R0_DESCREL) -O=$@ -n=$(DD_DESC)
	$(TOUCH) $(FLAGFILE)

$(ODIR) $(RDIR):
	@$(MD) $@


clean:
	$(RM) $(R0_DESCMOD) $(R0_DESCREL) $(R0_DESCMOD_FMT) $(R0_DESCREL_FMT) $(C0_DESCMOD) $(H0_DESCMOD) $(DD_DESCMOD)
