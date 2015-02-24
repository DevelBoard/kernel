all: build-buildroot

clean: clean-buildroot

distclean: distclean-buildroot

GREEN = \e[01;32m
NC = \e[00m
INFO = @/bin/echo -e "$(GREEN)*** Make: $@$(NC)"


build-buildroot:
	$(INFO)
	$(MAKE) -C $(@:build-%=%) develer_develboard_defconfig
	$(MAKE) -C $(@:build-%=%)
	rm -f buildroot/output/build/at91bootstrap3-*/.stamp*
	sed -i 's/sama5d4_xplainedsd_uboot_secure/sama5d4_xplainednf_uboot_secure/g' buildroot/.config
	$(MAKE) -C $(@:build-%=%)

clean-buildroot:
	$(INFO)
	$(MAKE) -C $(@:clean-%=%) clean

distclean-buildroot:
	$(INFO)
	$(MAKE) -C $(@:distclean-%=%) distclean
