THEOS_DEVICE_IP = 10.0.0.130
GO_EASY_ON_ME = 1
#THEOS_PACKAGE_SCHEME=rootless


PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
#PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)-$(VERSION.INC_BUILD_NUMBER)$(VERSION.EXTRAVERSION)


INSTALL_TARGET_PROCESSES = SpringBoard Siri Preferences

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
	ARCHS = arm64 arm64e
	TARGET = iphone:clang:15.5:15.0
else
	ARCHS = armv7 arm64 arm64e
	TARGET = iphone:clang:14.2:8.0
endif

include $(THEOS)/makefiles/common.mk

SDKVERSION = 16.5

TWEAK_NAME = SiriCoinControl

$(TWEAK_NAME)_FILES = Tweak.x Debug.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc


include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += siricoincontrolprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
