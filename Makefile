TARGET = simulator:clang:7.0

include theos/makefiles/common.mk

TWEAK_NAME = CycriptBonusFeatures
CycriptBonusFeatures_FILES = Tweak.xm
CycriptBonusFeatures_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk


