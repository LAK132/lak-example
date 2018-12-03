BINDIR = bin
OBJDIR = obj
INCDIR = inc
SRCDIR = src
SYSTEM = x64

CPPVER = c++17

# Set up sources
export SOURCES = example

# Set up submodules
SUBMODULES = lak
# Tell submodules where we are
export lak_SRC = $(INCDIR)/lak

# Set up the current project
example_SRC = $(SRCDIR)
example_INC = $(INCDIR)
example_OBJ = source.cpp
example_HDR = source.h
example_DEP = lak cql lak_types lak_utils glm sdl stb opengl

.PHONY: all
all: debug

ifeq ($(OS),Windows_NT)
##########################################
############ We're on Windows ############
##########################################

# Set up our environment
BINARY = example.exe
LIBDIR = lib
LIBS =
# LIBS = SDL2main.lib SDL2.lib

COMP = "cl.exe"
COMPOPT = /std:$(CPPVER) /nologo /EHa /MD /bigobj

LINK = "$(MSVC)/link.exe"
LINKOPT = /nologo

# Add our compiling options for debug mode
debug: COMPOPT += /Zi /DLTEST
debug: LINKOPT += /DEBUG
# Add out compiling options for release mode
release: COMPOPT += /DNDEBUG
release: LINKOPT +=

else
##########################################
############# We're on Linux #############
##########################################

BINARY = example
LIBDIR =
LIBS = dl SDL2 stdc++fs

COMP = g++-8
COMPOPT = -std=$(CPPVER) -pthread

LINK = $(COMP)
LINKOPT =

# Add our compiling options for debug mode
debug: COMPOPT += -g
debug: LINKOPT +=

# Add out compiling options for release mode
release: COMPOPT += -DNDEBUG
release: LINKOPT +=

endif

.DEFAULT:
	$(error Cannot find target $@)

ifeq ($(OS),Windows_NT)

define COMPILE_TEMPLATE =
$(OBJDIR)/$(SYSTEM)$(1)$(2).o: $(3)/$(2) $(4)
	$(info $(shell $(COMP) /c $$< /Fo$$@ $(5) $$(COMPOPT)))
endef

else

define COMPILE_TEMPLATE =
$(OBJDIR)/$(SYSTEM)$(1)$(2).o: $(3)/$(2) $(4)
	$(COMP) -c $$< -o $$@ $(5) $$(COMPOPT)
endef

endif

define SUBMODULE_TEMPLATE =
$(1)_MKF = $$($(1)_SRC)/Makefile
$$($(1)_SRC):
	( if [ ! -d $$@ ]; then $$(error Submodule $$@ not found, use `git submodule update --init --recursive` to initialise submodules); fi )
$$($(1)_MKF): | $$($(1)_SRC)
	( if [ ! -f $$@ ]; then $$(error Submodule $$($(1)_SRC) not initialised, use `git submodule update --init --recursive` to initialise submodules) ; fi )
include $$($(1)_MKF)
endef

$(foreach sub,$(SUBMODULES),$(eval $(call SUBMODULE_TEMPLATE,$(sub))))
$(foreach src,$(SOURCES),$(foreach obj,$($(src)_OBJ),$(eval $(call COMPILE_TEMPLATE,$(src),$(obj),$(strip $($(src)_SRC)),$(foreach hdr,$(strip $($(src)_HDR)), $(strip $($(src)_SRC))/$(hdr)) $(foreach dep,$(strip $($(src)_DEP)),$(foreach depobj,$(strip $($(dep)_OBJ)), $(strip $($(dep)_SRC))/$(depobj)) $(foreach dephdr,$(strip $($(dep)_HDR)), $(strip $($(dep)_SRC))/$(dephdr))),$(foreach inc,$(strip $($(src)_INC)), -I$(strip $(inc))) $(foreach dep,$(strip $($(src)_DEP)),$(if $(strip $($(dep)_SRC)),-I$(strip $($(dep)_SRC)),$(info bad dep $(dep) $($(dep)_SRC))) $(foreach depinc,$(strip $($(dep)_INC)), -I$(strip $(depinc))))))))

ALLOBJ = $(foreach src,$(SOURCES),$(foreach obj,$($(src)_OBJ),$(OBJDIR)/$(SYSTEM)$(src)$(obj).o))
ALLHDR = $(foreach src,$(SOURCES),$(foreach hdr,$($(src)_HDR),$($(src)_SRC)/$(hdr)))

ifeq ($(OS),Windows_NT)

ALLLIB = $(foreach libdir,$(LIBDIR),/LIBPATH:$(libdir)) $(foreach lib,$(LIBS),-l$(lib))

debug release: $(ALLOBJ) | $(BINDIR) $(OBJDIR)
	$(LINK) $(ALLOBJ) $(LINKOPT) $(ALLLIB) /OUT:$(BINDIR)/$(BINARY)

else

ALLLIB = $(foreach libdir,$(LIBDIR),-L$(libdir)) $(foreach lib,$(LIBS),-l$(lib))

debug release: $(ALLOBJ) | $(BINDIR) $(OBJDIR)
	$(LINK) $(ALLOBJ) $(COMPOPT) $(ALLLIB) -o $(BINDIR)/$(BINARY)

clean:
	rm -f $(BINDIR)/*
	rm -f $(OBJDIR)/*

endif
