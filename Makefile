ARCHS = arm64 armv7

include theos/makefiles/common.mk

TWEAK_NAME = GroupIndicators
GroupIndicators_FILES = Tweak.xm
GroupIndicators_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSMS"
SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
