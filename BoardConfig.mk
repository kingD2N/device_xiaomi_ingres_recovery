#
# Copyright (C) 2022 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/ingres

BOARD_SYSTEMSDK_VERSIONS := 31

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a-branchprot
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := kryo300

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a75

# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    odm \
    product \
    recovery \
    system \
    system_ext \
    vbmeta \
    vbmeta_system \
    vendor \
    vendor_boot \
    vendor_dlkm

# AVB
BOARD_AVB_ENABLE := true
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA2048
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1

BOARD_AVB_VBMETA_SYSTEM := system system_ext product
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2

# Bootloader
TARGET_NO_BOOTLOADER := false
TARGET_USES_UEFI := true
TARGET_USES_REMOTEPROC := true
TARGET_NO_KERNEL := false
BOARD_RAMDISK_USE_LZ4 := true

# Build
BUILD_BROKEN_NINJA_USES_ENV_VARS += SDCLANG_AE_CONFIG SDCLANG_CONFIG SDCLANG_SA_ENABLE
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_NINJA_USES_ENV_VARS += RTIC_MPGEN
BUILD_BROKEN_USES_BUILD_HOST_SHARED_LIBRARY := true
BUILD_BROKEN_USES_BUILD_HOST_STATIC_LIBRARY := true
BUILD_BROKEN_USES_BUILD_HOST_EXECUTABLE := true
BUILD_BROKEN_USES_BUILD_COPY_HEADERS := true

# Crypto
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
BOARD_USES_QCOM_FBE_DECRYPTION := true
BOARD_USES_METADATA_PARTITION := true
PLATFORM_VERSION := 99.87.36
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)

# File systems
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_USES_VENDOR_DLKMIMAGE := true

# Kernel
BOARD_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_ARGS := --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_USES_GENERIC_KERNEL_IMAGE := true

TARGET_COMPILE_WITH_MSM_KERNEL := false
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true
BOARD_KERNEL_IMAGE_NAME := Image
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel

BOARD_KERNEL_BASE        := 0x00000000
BOARD_KERNEL_PAGESIZE    := 4096
BOARD_KERNEL_TAGS_OFFSET := 0x01E00000
BOARD_RAMDISK_OFFSET     := 0x02000000

BOARD_KERNEL_CMDLINE := video=vfb:640x400,bpp=32,memsize=3072000
BOARD_KERNEL_CMDLINE += console=ttyMSM0,115200n8 earlycon msm_geni_serial.con_enabled=1 androidboot.selinux=permissive
BOARD_BOOTCONFIG := androidboot.hardware=qcom androidboot.memcg=1 androidboot.usbcontroller=a600000.dwc3
BOARD_BOOTCONFIG += androidboot.console=ttyMSM0

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_KERNEL-GKI_BOOTIMAGE_PARTITION_SIZE := $(BOARD_BOOTIMAGE_PARTITION_SIZE)
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_USERDATAIMAGE_PARTITION_SIZE := 48318382080
BOARD_PERSISTIMAGE_PARTITION_SIZE := 33554432
BOARD_METADATAIMAGE_PARTITION_SIZE := 16777216
BOARD_DTBOIMG_PARTITION_SIZE := 24117248
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)

BOARD_SUPER_PARTITION_SIZE := 9126805504
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 9122611200
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := system system_ext product vendor vendor_dlkm odm
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600

BOARD_PERSISTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4

TARGET_COPY_OUT_ODM := odm
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true

# Properties
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop

# Recovery
# Tanpa tanda kutip: nilai ini diekspor ke JSON Soong (RecoveryPixelFormat) di Android 16;
# kutip ganda merusak JSON ("Expecting , delimiter" di soong.*.extra.variables).
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab

# Screen density
TARGET_SCREEN_HEIGHT  := 2400
TARGET_SCREEN_DENSITY := 840
TARGET_SCREEN_WIDTH   := 1080

# TWRP specific build flags
#TW_THEME := portrait_hdpi
RECOVERY_SDCARD_ON_DATA := true
TARGET_RECOVERY_QCOM_RTC_FIX := true
TW_EXCLUDE_DEFAULT_USB_INIT := true
TW_EXCLUDE_ENCRYPTED_BACKUPS := false
TW_EXTRA_LANGUAGES := true
TW_INCLUDE_NTFS_3G := true
TW_USE_TOOLBOX := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true
TW_EXCLUDE_APEX := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_LIBRESETPROP := true
TW_STATUS_ICONS_ALIGN := center
TW_CUSTOM_CPU_POS := "50"
TW_CUSTOM_CLOCK_POS := "600"
TW_CUSTOM_BATTERY_POS := "800"

# TWRP Display flags
TW_BRIGHTNESS_PATH := "/sys/class/backlight/panel0-backlight/brightness"
TW_MAX_BRIGHTNESS := 2047
TW_DEFAULT_BRIGHTNESS := 1024
TW_NO_SCREEN_BLANK := true
# Layar ingres 120Hz (diambil dari tree marble)
TW_FRAMERATE := 120

# Tambahan dari tree marble
# - Device ID pakai serialno (stabil antar format/flash)
# - Fingerprint & incremental diambil dari ROM terpasang (bantu assert zip OTA/ROM)
# - mke2fs untuk membuat filesystem ext4 saat format
TW_USE_SERIALNO_PROPERTY_FOR_DEVICE_ID := true
TW_OVERRIDE_SYSTEM_PROPS := \
    "ro.build.fingerprint=ro.vendor.build.fingerprint;ro.build.version.incremental"
TARGET_USES_MKE2FS := true

# TWRP Haptics (vibrator) -- mengikuti pola OrangeFox-For-Marble (yudharn)
# Dua HAL jalan berdampingan di recovery:
#   1. HAL ASLI ingres  : vendor.xiaomi.hardware.vibratorfeature (IVibrator/vibratorfeature)
#                         -- prebuilt, selalu ada, jadi getar dasar selalu jalan (cadangan).
#   2. HAL qcom open source (IVibrator/default) -- DIBUILD DARI SOURCE vendor/qcom/opensource/vibrator
#                         milik manifest itu sendiri (ABI libc++ pasti cocok). Workflow menambahkan
#                         nama input "awinic_haptic"/"aw8697_haptic" (motor ingres) ke HAL ini.
#                         HAL ini punya efek Click/Double click/Tick/Thud/Pop/Heavy click untuk
#                         menu "Haptic feedback" (patch bootable/recovery di workflow).
# Recovery yang sudah dipatch memilih IVibrator/default kalau sudah jalan, kalau tidak kembali ke
# FQNAME di bawah. Recovery tanpa patch tetap memakai FQNAME (HAL Xiaomi).
TW_SUPPORT_INPUT_AIDL_HAPTICS := true
TW_SUPPORT_INPUT_AIDL_HAPTICS_FQNAME := "IVibrator/vibratorfeature"

# HAL qcom hanya dibuild kalau workflow BERHASIL menambahkan dukungan motor awinic ke source
# (penanda vendor/qcom/opensource/vibrator/.ingres_awinic). Tanpa itu HAL qcom tetap terdaftar
# walau tidak menemukan motor -> recovery memilihnya -> tidak bergetar. Jadi lebih aman dilewati.
# Penanda hanya dibuat untuk layout lama (aidl/Vibrator.cpp, fox_12.1); layout baru
# (aidl/VibratorOL/, fox_16.0) butuh library tambahan -- dilewati, HAL Xiaomi yang dipakai.
ifneq ($(wildcard vendor/qcom/opensource/vibrator/.ingres_awinic),)
TARGET_RECOVERY_DEVICE_MODULES += \
    vendor.qti.hardware.vibrator.service \
    vendor.qti.hardware.vibrator.impl \
    libqtivibratoreffect
RECOVERY_BINARY_SOURCE_FILES += \
    $(TARGET_OUT_VENDOR_EXECUTABLES)/hw/vendor.qti.hardware.vibrator.service
RECOVERY_LIBRARY_SOURCE_FILES += \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/vendor.qti.hardware.vibrator.impl.so \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/libqtivibratoreffect.so
endif
TW_EXCLUDE_TWRPAPP := true

# TWRP Version
TW_DEVICE_VERSION := POCO F4 GT

# Load kernel modules for touch & vibrator
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/modules.load.recovery))
# TW_LOAD_VENDOR_MODULES DIKEMBALIKAN (bukan dihapus lagi) -- root cause "0 modul berhasil
# dimuat" TERNYATA BUKAN race condition seperti dugaan awal. Dicek langsung isi fisik
# recovery/root/vendor/lib/modules/1.1/: yang BENAR-BENAR ada di sana cuma fts_touch_spi.ko
# dan xiaomi_touch.ko. Daftar lama berisi 7 nama modul, 5 DI ANTARANYA TIDAK PERNAH ADA
# FILENYA (adsp_loader_dlkm.ko, atmel_mxt_ts.ko, focaltech_fts.ko, nt36xxx-i2c.ko,
# nt36xxx-spi.ko, synaptics_dsx.ko) -- percobaan load modul yang filenya tidak ada itulah
# yang bikin hitungan "0 berhasil" (atau menghalangi modul asli ke-load kalau nama yang
# tidak ada itu diproses lebih dulu), BUKAN soal timing/race. Konfirmasi IC touch asli:
# firmware di proprietary-files.txt adalah st_fts_l10.ftb / stm_fts_production_limits.csv
# (STMicroelectronics FTS), cocok dengan fts_touch_spi.ko. Dengan daftar berisi HANYA modul
# yang benar-benar ada ini, dialog "Hardware GUI control" seharusnya tidak muncul lagi
# (syaratnya "0 modul berhasil" tidak lagi terpenuhi) DAN touch benar-benar termuat --
# bukan cuma dialognya yang hilang seperti pendekatan sebelumnya. TETAP WAJIB dites ulang
# setelah build+flash untuk konfirmasi akhir.
TW_LOAD_VENDOR_MODULES := "fts_touch_spi.ko xiaomi_touch.ko"

# The path to a temperature sensor
TW_CUSTOM_CPU_TEMP_PATH := "/sys/devices/virtual/thermal/thermal_zone50/temp"

# Namespace definition for librecovery_updater
SOONG_CONFIG_NAMESPACES += ufsbsg
SOONG_CONFIG_ufsbsg += ufsframework
SOONG_CONFIG_ufsbsg_ufsframework := bsg
