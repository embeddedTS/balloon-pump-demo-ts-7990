################################################################################
#
# sfxx-driver
#
################################################################################

SFXX_DRIVER_VERSION = master
SFXX_DRIVER_SITE = $(call github,Sensirion,sfxx,$(SFXX_DRIVER_VERSION))

# No License provided by driver sources

define SFXX_DRIVER_LINUX_CONFIG_FIXUPS
        $(call KCONFIG_ENABLE_OPT,CONFIG_CRC8)
endef

$(eval $(kernel-module))
$(eval $(generic-package))
