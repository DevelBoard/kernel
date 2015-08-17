# use `make FORCE_CCACHE=1` to force enable ccache

all: build-buildroot

clean: clean-buildroot

distclean: distclean-buildroot

GREEN = \e[01;32m
NC = \e[00m
INFO = @/bin/echo -e "$(GREEN)*** Make: $@$(NC)"

# don't pass special options to sub-makes (e.g. FORCE_CCACHE=1)
MAKEOVERRIDES := $(filter-out FORCE_CCACHE=%,$(MAKEOVERRIDES))

# internal variables
_develboard_dir = board/develer/develboard


build-buildroot:
	$(INFO)
	$(MAKE) -C $(@:build-%=%) develer_develboard_defconfig
ifeq ($(FORCE_CCACHE),1)
	cat buildroot/$(_develboard_dir)/buildroot-fragments/ccache.config >> $(@:build-%=%)/.config
	yes "" | $(MAKE) -C $(@:build-%=%) oldconfig
endif
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
