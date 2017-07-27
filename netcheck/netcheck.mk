#############################################################
#
# upnp netcheck
#
#############################################################
NETCHECK_VERSION = 20170727
NETCHECK_SITE = $(TOPDIR)/../vendor/amlogic/external/platinum/netcheck/src
NETCHECK_SITE_METHOD = local
NETCHECK_DEPENDENCIES = upnp-app

define NETCHECK_BUILD_CMDS
    $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) all
endef

define NETCHECK_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/etc/dlna
    $(TARGET_CONFIGURE_OPTS) $(MAKE) CC=$(TARGET_CC) -C $(@D) install
endef

$(eval $(generic-package))
