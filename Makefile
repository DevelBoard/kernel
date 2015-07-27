all: build-buildroot

clean: clean-buildroot

distclean: distclean-buildroot


GREEN = \e[01;32m
NC = \e[00m
INFO = @/bin/echo -e "$(GREEN)*** Make: $@$(NC)"

# internal variables
_defconfig = "develer_develboard_defconfig"
_opt_ccache = "BR2_CCACHE=y"

# use `make CCACHE_ENABLE=[1|0]` to enable/disable ccache
CCACHE_ENABLE ?= $(shell grep -q "$(_opt_ccache)" buildroot/configs/$(_defconfig) && echo 1 || echo 0)

# don't pass special options to sub-makes (e.g. CCACHE_ENABLE=1)
MAKEOVERRIDES := $(filter-out CCACHE_ENABLE=%,$(MAKEOVERRIDES))


build-buildroot:
	$(INFO)
	$(MAKE) -C $(@:build-%=%) $(_defconfig)
ifeq ($(CCACHE_ENABLE),0)
	# ccache disabled
	@if grep -q "$(_opt_ccache)" $(@:build-%=%)/.config; then \
		sed -i "/$(_opt_ccache)/d" $(@:build-%=%)/.config; \
		yes "" | $(MAKE) -C $(@:build-%=%) oldconfig; \
	fi
else
	# ccache enabled
	@if ! grep -q "$(_opt_ccache)" $(@:build-%=%)/.config; then \
		echo "$(_opt_ccache)" >> $(@:build-%=%)/.config; \
		yes "" | $(MAKE) -C $(@:build-%=%) oldconfig; \
	fi
endif
	$(MAKE) -C $(@:build-%=%)

clean-buildroot:
	$(INFO)
	$(MAKE) -C $(@:clean-%=%) clean

distclean-buildroot:
	$(INFO)
	$(MAKE) -C $(@:distclean-%=%) distclean
