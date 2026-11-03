#!/system/bin/sh
#######################################################################################
# APatch Boot Image Unpatcher
# Imported from https://github.com/bmax121/APatch/blob/main/app/src/main/assets/boot_unpatch.sh
#######################################################################################

MODPATH=${0%/*}
ARCH=$(getprop ro.product.cpu.abi)

# Load utility functions
. "$MODPATH/util_functions.sh"

BOOTIMAGE=$1

[ -e "$BOOTIMAGE" ] || { echo "- $BOOTIMAGE does not exist!"; exit 1; }

echo "- Target image: $BOOTIMAGE"

  # Check for dependencies
command -v magiskboot >/dev/null 2>&1 || { echo "- Command magiskboot not found!"; exit 1; }
command -v kptools >/dev/null 2>&1 || { echo "- Command kptools not found!"; exit 1; }

. "$MODPATH/engine_functions.sh"
select_engine 0.13.9 || exit 1
if [ ! -f kernel ]; then
  magiskboot unpack "$BOOTIMAGE" || exit 1
fi
restore_kernel || exit 1
magiskboot repack "$BOOTIMAGE" || exit 1
[ -f new-boot.img ] || exit 1
backup_boot || exit 1
flash_image new-boot.img "$BOOTIMAGE" || { save_image_to_storage new-boot.img; exit 1; }
rm -rf "$KPNDIR/kpm" "$KPNDIR/package_config" "$KPNDIR/rehook" || exit 1
rm -f /data/adb/service.d/kp-next.sh "$MODROOT/unresolved" || exit 1
echo "- Flash successful"
