#!/system/bin/sh
#
# Diadaptasi dari OFRP marble (runatboot.sh) untuk ingres.
# Dijalankan otomatis oleh OrangeFox saat recovery start: menyetel nama
# perangkat sesuai region (ingres = satu device, dua nama dagang).
#   CN     -> Redmi K50 Gaming
#   lainnya -> POCO F4 GT (global)
#

LOGF=/tmp/recovery.log

set_model()
{
    brand="$1"
    model="$2"
    echo "$model" > /config/usb_gadget/g1/strings/0x409/product 2>/dev/null
    resetprop "ro.product.brand" "$brand"
    resetprop "ro.orangefox.device_model" "$model"
    echo "I:unified-script: setting $model props" >> $LOGF
}

region=$(getprop ro.boot.hwc)
echo "I:unified-script: detected region: $region" >> $LOGF

case "$region" in
    CN)
        set_model "Redmi" "Redmi K50 Gaming"
        ;;
    *)
        set_model "POCO" "POCO F4 GT"
        ;;
esac

exit 0
