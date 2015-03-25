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

	$(eval outdir := buildroot/output/build/at91bootstrap3-v3.7.1)
	sed -i 's/CONFIG_NANDFLASH=y/CONFIG_SDCARD=y/g' $(outdir)/.config
	sed -i 's/# CONFIG_SDCARD is not set/# CONFIG_NANDFLASH is not set/g' $(outdir)/.config
	$(MAKE) -C $(outdir) defconfig

	rm -f $(outdir)/.stamp_built
	$(MAKE) -C $(@:build-%=%)

clean-buildroot:
	$(INFO)
	$(MAKE) -C $(@:clean-%=%) clean

distclean-buildroot:
	$(INFO)
	$(MAKE) -C $(@:distclean-%=%) distclean
