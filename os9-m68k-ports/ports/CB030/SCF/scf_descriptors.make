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

SCFDSC		= term   t1   t10   t11   t12   
SCFDSCR		= term.r t1.r t10.r t11.r t12.r 

build: $(RDIR) $(ODIR) $(SCFDSC)

term: $(RDIR)/term.r $(SLIB)
	$(LC) $(LFLAGS) $(RDIR)/$*.r -O=$(ODIR)/$*
	$(TOUCH) $(FLAGFILE)

t1: $(RDIR)/t1.r $(SLIB)
	$(LC) $(LFLAGS) $(RDIR)/$*.r -O=$(ODIR)/$*
	$(TOUCH) $(FLAGFILE)


t10: $(RDIR)/t10.r $(SLIB)
	$(LC) $(LFLAGS) $(RDIR)/$*.r -O=$(ODIR)/$*
	$(TOUCH) $(FLAGFILE)

t11: $(RDIR)/t11.r $(SLIB)
	$(LC) $(LFLAGS) $(RDIR)/$*.r -O=$(ODIR)/$*
	$(TOUCH) $(FLAGFILE)

t12: $(RDIR)/t12.r $(SLIB)
	$(LC) $(LFLAGS) $(RDIR)/$*.r -O=$(ODIR)/$*
	$(TOUCH) $(FLAGFILE)

t13: $(RDIR)/t13.r $(SLIB)
	$(LC) $(LFLAGS) $(RDIR)/$*.r -O=$(ODIR)/$*
	$(TOUCH) $(FLAGFILE)

$(SCFDSCR): $(SYSDEFS) $(MAKER)

$(ODIR) $(RDIR):
	@$(MD) $@

clean:
	$(RM) $(RDIR)/term.r $(ODIR)/term
	$(RM) $(RDIR)/t1.r $(ODIR)/t1
	$(RM) $(RDIR)/t10.r $(ODIR)/t10
	$(RM) $(RDIR)/t11.r $(ODIR)/t11
	$(RM) $(RDIR)/t12.r $(ODIR)/t12
	$(RM) $(RDIR)/t13.r $(ODIR)/t13
