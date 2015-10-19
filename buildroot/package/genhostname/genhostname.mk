################################################################################
#
# genhostname
#
################################################################################

GENHOSTNAME_VERSION = 1.1.0
GENHOSTNAME_LICENSE = MIT
GENHOSTNAME_SITE = package/genhostname
GENHOSTNAME_SITE_METHOD = local

define GENHOSTNAME_BUILD_CMDS
    $(MAKE) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS) -std=gnu99" LD="$(TARGET_LD)" -C $(@D) genhostname
endef

define GENHOSTNAME_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/genhostname $(TARGET_DIR)/usr/sbin/genhostname
    $(INSTALL) -D -m 0644 package/genhostname/genhostname.service $(TARGET_DIR)/etc/systemd/system/genhostname.service
endef

$(eval $(generic-package))
