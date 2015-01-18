# World APN list, Device Hammerhead will be override with Google's Stock APN.
ifeq ($(TARGET_IS_HAMMERHEAD),true)

PRODUCT_COPY_FILES += \
    vendor/kdp/prebuilt/common/etc/hammerhead-apns-conf.xml:system/etc/apns-conf.xml
else
PRODUCT_COPY_FILES += \
    vendor/kdp/prebuilt/common/etc/apns-conf.xml:system/etc/apns-conf.xml
endif

# World SPN overrides list
PRODUCT_COPY_FILES += \
    vendor/kdp/prebuilt/common/etc/spn-conf.xml:system/etc/spn-conf.xml

# Selective SPN list for operator number who has the problem.
PRODUCT_COPY_FILES += \
    vendor/kdp/prebuilt/common/etc/selective-spn-conf.xml:system/etc/selective-spn-conf.xml


# Telephony packages
PRODUCT_PACKAGES += \
    Mms \
    Stk \
    CellBroadcastReceiver \
    VoiceDialer \
    WhisperPush

# Mms depends on SoundRecorder for recorded audio messages
PRODUCT_PACKAGES += \
    SoundRecorder

# Default ringtone
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.ringtone=Orion.ogg
