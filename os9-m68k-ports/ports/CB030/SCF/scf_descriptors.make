#############################################################################
# SCF descriptor modules
#############################################################################

# disable object file rules as we call the linker directly
-bo

SDIR		= $(SRCROOT)/IO/SCF/DESC	# SCF descriptor sources
ODIR		= ../CMDS/BOOTOBJS
RDIR		= ./RELS
MAKER		= ./scf_descriptors.make	# this file
FLAGFILE	= $(ODIR)/.updated
SYSDEFS		= ../systype.d
RFLAGS		= -q -u=. -u=$(OSDEFS)
SLIB		= $(SYSRELS)/sys.l
PERM		= -p=577			# W:er, GO:ewr module permissions
LFLAGS		= -l=$(SLIB) -gu=0.0 $(PERM)

SCFDSC		= term   t1
SCFDSCR		= term.r t1.r

build: $(RDIR) $(ODIR) $(SCFDSC)
	$(RC) $(RFLAGS) -u=$(SDIR) crt80.a -o=RELS\crt80.r
	$(LC) $(LFLAGS) RELS\crt80.r -O=..\CMDS\BOOTOBJS\crt80

	$(RC) $(RFLAGS) -u=$(SDIR) crt81.a -o=RELS\crt81.r
	$(LC) $(LFLAGS) RELS\crt81.r -O=..\CMDS\BOOTOBJS\crt81

	$(RC) $(RFLAGS) -u=$(SDIR) crt82.a -o=RELS\crt82.r
	$(LC) $(LFLAGS) RELS\crt82.r -O=..\CMDS\BOOTOBJS\crt82

term: $(RDIR)/term.r $(SLIB)
	$(LC) $(LFLAGS) $(RDIR)/$*.r -O=$(ODIR)/$*
	$(TOUCH) $(FLAGFILE)

t1: $(RDIR)/t1.r $(SLIB)
	$(LC) $(LFLAGS) $(RDIR)/$*.r -O=$(ODIR)/$*
	$(TOUCH) $(FLAGFILE)

$(SCFDSCR): $(SYSDEFS) $(MAKER)

$(ODIR) $(RDIR):
	@$(MD) $@

clean:
	$(RM) $(RDIR)/term.r $(ODIR)/term
	$(RM) $(RDIR)/t1.r $(ODIR)/t1
	$(RM) $(RDIR)/crt80.r $(ODIR)/crt80
	$(RM) $(RDIR)/crt81.r $(ODIR)/crt81
	$(RM) $(RDIR)/crt82.r $(ODIR)/crt82
