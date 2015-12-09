ARCHS = arm64 armv7

include theos/makefiles/common.mk

BUNDLE_NAME = GroupIndicators
GroupIndicators_FILES = GroupIndicators.mm
GroupIndicators_INSTALL_PATH = /Library/PreferenceBundles
GroupIndicators_FRAMEWORKS = UIKit
GroupIndicators_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/GroupIndicators.plist$(ECHO_END)
