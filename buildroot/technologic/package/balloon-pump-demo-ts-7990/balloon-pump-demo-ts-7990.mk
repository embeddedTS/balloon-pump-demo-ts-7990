################################################################################
#
# BALLOON_PUMP_DEMO_TS_7990
#
################################################################################

BALLOON_PUMP_DEMO_TS_7990_VERSION = refresh
BALLOON_PUMP_DEMO_TS_7990_SITE = $(call github,embeddedTS,balloon-pump-demo-ts-7990,$(BALLOON_PUMP_DEMO_TS_7990_VERSION))
BALLOON_PUMP_DEMO_TS_7990_LICENSE = BSD-2-Clause
BALLOON_PUMP_DEMO_TS_7990_LICENSE_FILES = LICENSE
BALLOON_PUMP_DEMO_TS_7990_INSTALL_STAGING = YES

$(eval $(qmake-package))
