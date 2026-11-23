# TWRP device tree for Redmi K50 Gaming / Poco F4 GT

> **Catatan:** branch/repo ini bernama "TWRP" dan memakai konvensi penamaan produk `twrp_ingres`
> (standar bersama semua tree turunan TWRP), tapi tree ini di-build sebagai **OrangeFox** — lihat
> `fox_ingres.mk` untuk pengaturan khusus OrangeFox-nya, dan `vendorsetup.sh` untuk variabel
> `FOX_*`/`OF_*`-nya. Nama "TWRP" di sini murni penamaan branch, bukan penanda jenis recovery yang
> dihasilkan.

The POCO F4 GT (codenamed _"ingres"_) is a high-end gaming smartphone from POCO.

It was globally released in late April 2022.

## Device specifications

Basic   | Spec Sheet
-------:|:-------------------------
Platform | Snapdragon® 8 Gen 1 (SM8450)
RAM & Storage | 8GB/128GB, 12GB/256GB (LPDDR5 RAM, UFS 3.1 storage)
Shipped Android Version | 12
Battery | Non-removable, 4700 mAh
Display | 6.67" flat AMOLED DotDisplay, 120Hz, 2400x1080 (~395 ppi)
Rear camera | 64MP IMX686 wide angle, 8MP ultra wide-angle, 2MP macro
Front camera | 20MP IMX596 in-display

## Device picture

![POCO F4 GT](https://i01.appmifile.com/webfile/globalimg/products/pc/poco-f4-gt/specs01.png "POCO F4 GT in all colours")

## Features

Works:

- [X] ADB
- [X] Decryption
- [X] Display
- [X] Fasbootd
- [X] Flashing
- [X] MTP
- [X] Sideload
- [X] USB OTG
- [X] Vibrator

## Vibrator (pola OrangeFox-For-Marble)

| HAL | Instance | Keterangan |
|---|---|---|
| Xiaomi `vibratorfeature` (prebuilt ingres) | `IVibrator/vibratorfeature` | Selalu jalan, cadangan getar dasar |
| qcom open source (dibuild dari source manifest) | `IVibrator/default` | Efek Click/Double click/Tick/Thud/Pop/Heavy click untuk menu **Haptic feedback** |

- Workflow menambahkan nama input motor ingres (`awinic_haptic`, `aw8697_haptic`) ke source
  `vendor/qcom/opensource/vibrator`, lalu membuat penanda `.ingres_awinic`. HAL qcom hanya
  dibuild kalau penanda itu ada (saat ini: fox_12.1).
- Recovery yang dipatch memilih `IVibrator/default` bila sudah terdaftar, kalau tidak memakai HAL Xiaomi.

## Credits

- [yudharn/OrangeFox-For-Marble](https://github.com/yudharn/OrangeFox-For-Marble) — pola HAL vibrator qcom + menu Haptic feedback
- [Ctapchuk/android_device_xiaomi_marble-OFRP](https://github.com/Ctapchuk/android_device_xiaomi_marble-OFRP) — `runatboot.sh`, dan beberapa flag OrangeFox
- Maintainer: **kingD2N**

## To use it:

```
fastboot flash recovery_ab out/target/product/ingres/recovery.img

```
