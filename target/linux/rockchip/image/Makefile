#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

DEVICE_VARS += UBOOT_DEVICE_NAME

define Build/Compile
	$(CP) $(LINUX_DIR)/COPYING $(KDIR)/COPYING.linux
endef

### Image scripts ###
define Build/boot-common
	# This creates a new folder copies the dtb (as rockchip.dtb) 
	# and the kernel image (as kernel.img)
	rm -fR $@.boot
	mkdir -p $@.boot

	$(CP) $(DTS_DIR)/$(DEVICE_DTS).dtb $@.boot/rockchip.dtb
	$(CP) $(IMAGE_KERNEL) $@.boot/kernel.img
endef

define Build/boot-script
  # echo "====================================== $(1) =========================================="
	# Make an U-boot image and copy it to the boot partition
	mkimage -A arm -O linux -T script -C none -a 0 -e 0 -d $(if $(1),$(1),mmc).bootscript $@.boot/boot.scr
endef

define Build/pine64-img
	# Creates the final SD/eMMC images, 
	# combining boot partition, root partition as well as the u-boot bootloader

	# Generate a new partition table in $@ with 32 MiB of 
	# alignment padding for the idbloader and u-boot to fit:
	# http://opensource.rock-chips.com/wiki_Boot_option#Boot_flow
	#
	# U-Boot SPL expects the U-Boot ITB to be located at sector 0x4000 (8 MiB) on the MMC storage
	$(SCRIPT_DIR)/gen_image_generic.sh \
		$@ \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $@.boot \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(IMAGE_ROOTFS) \
		32768
#        +--------+----------------+----------+-------------+---------+
#        | Boot   | Terminology #1 | Actual   | Rockchip    | Image   |
#        | stage  |                | program  |  Image      | Location|
#        | number |                | name     |   Name      | (sector)|
#        +--------+----------------+----------+-------------+---------+
#        | 1      |  Primary       | ROM code | BootRom     |         |
#        |        |  Program       |          |             |         |
#        |        |  Loader        |          |             |         |
#        |        |                |          |             |         |
#        | 2      |  Secondary     | U-Boot   |idbloader.img| 0x40    | pre-loader
#        |        |  Program       | TPL/SPL  |             |         |
#        |        |  Loader (SPL)  |          |             |         |
#        |        |                |          |             |         |
#        | 3      |  -             | U-Boot   | u-boot.itb  | 0x4000  | including u-boot and atf
#        |        |                |          | uboot.img   |         | only used with miniloader
#        |        |                |          |             |         |
#        |        |                | ATF/TEE  | trust.img   | 0x6000  | only used with miniloader
#        |        |                |          |             |         |
#        | 4      |  -             | kernel   | boot.img    | 0x8000  |
#        |        |                |          |             |         |
#        | 5      |  -             | rootfs   | rootfs.img  | 0x40000 |
#        +--------+----------------+----------+-------------+---------+
	# Copy the idbloader and the u-boot image to the image at sector 0x40 and 0x4000
	dd if="$(STAGING_DIR_IMAGE)"/$(UBOOT_DEVICE_NAME)-idbloader.img of="$@" seek=64 conv=notrunc
	dd if="$(STAGING_DIR_IMAGE)"/$(UBOOT_DEVICE_NAME)-u-boot.itb of="$@" seek=16384 conv=notrunc
endef

### Devices ###
define Device/Default
  PROFILES := Default
  KERNEL := kernel-bin
  IMAGES := sysupgrade.img.gz
  SUPPORTED_DEVICES := $(subst _,$(comma),$(1))
  DEVICE_DTS = rockchip/$$(SOC)-$(lastword $(subst _, ,$(1)))
endef

define Device/embedfire_doornet1
  DEVICE_VENDOR := EmbedFire
  DEVICE_MODEL := DoorNet1
  SOC := rk3328
  DEVICE_DTS := rockchip/rk3328-doornet1
  UBOOT_DEVICE_NAME := doornet1-rk3328
  IMAGE/sysupgrade.img.gz := boot-common | boot-script doornet1 | pine64-img | gzip | append-metadata
  DEVICE_PACKAGES := kmod-usb-net-rtl8152 kmod-usb-serial-cp210x rtl8723bu-firmware
endef
TARGET_DEVICES += embedfire_doornet1

# include $(SUBTARGET).mk

$(eval $(call BuildImage))
