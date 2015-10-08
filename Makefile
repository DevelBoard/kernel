# use `make FORCE_CCACHE=1` to force enable ccache
# use `make FORCE_TOOLCHAIN_EXTERNAL=1` to force enable precompiled external toolchain

all: build-buildroot

clean: clean-buildroot

distclean: distclean-buildroot

GREEN = \e[01;32m
NC = \e[00m
INFO = @/bin/echo -e "$(GREEN)*** Make: $@$(NC)"

# don't pass special options to sub-makes (e.g. FORCE_CCACHE=1)
MAKEOVERRIDES := $(filter-out FORCE_CCACHE=%,$(MAKEOVERRIDES))
MAKEOVERRIDES := $(filter-out FORCE_TOOLCHAIN_EXTERNAL=%,$(MAKEOVERRIDES))

# Support out-of-tree builds
O ?= buildroot

# internal variables
_develboard_dir = board/develer/develboard
_fragments_dir = $(_develboard_dir)/buildroot-fragments

configure-buildroot:
	$(INFO)
	$(MAKE) -C $(@:configure-%=%) develer_develboard_defconfig
ifeq ($(FORCE_CCACHE),1)
	cat buildroot/$(_fragments_dir)/ccache.config >> $(O)/.config
	yes "" | $(MAKE) -C $(@:configure-%=%) oldconfig
endif
ifeq ($(FORCE_TOOLCHAIN_EXTERNAL),1)
	cat buildroot/$(_fragments_dir)/toolchain-external.config >> $(O)/.config
	yes "" | $(MAKE) -C $(@:configure-%=%) oldconfig
endif

build-buildroot:
	$(INFO)
	$(MAKE) -C $(@:build-%=%)

clean-buildroot:
	$(INFO)
	$(MAKE) -C $(@:clean-%=%) clean

distclean-buildroot:
	$(INFO)
	$(MAKE) -C $(@:distclean-%=%) distclean

toolchain:
	$(MAKE) -Cbuildroot BR2_EXTERNAL=$(_develboard_dir)/arm-toolchain toolchain_defconfig
	$(MAKE) -Cbuildroot
