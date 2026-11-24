#!/usr/bin/env bash
# ==============================================================================
#  Build OrangeFox Recovery untuk ingres (POCO F4 GT) di server sendiri,
#  lalu upload hasilnya (recovery.img + zip OrangeFox + log) ke GoFile.
#
#  Isi sama dengan workflow "Recovery OFOX Build" (branch OFOX_New):
#  patch haptic, dukungan motor awinic, perbaikan openaes, foto maintainer, dll.
#
#  Lokasi resmi script ini: repo PUBLIC kingD2N/device_xiaomi_ingres_recovery (branch OFOX_New),
#  folder server/. Patch haptic ada di folder patches/ repo yang sama.
#
#  Pakai (jalankan di dalam byobu supaya aman kalau koneksi Termius putus):
#     bash build_ofox_ingres.sh                 -> MENU pilihan (manifest, branch, varian, patch)
#     bash build_ofox_ingres.sh fox_16.0        -> langsung build tanpa menu
#     bash build_ofox_ingres.sh fox_12.1        -> manifest fox_12.1
#  Argumen: [MANIFEST] [BRANCH_TREE] [VARIAN] [NOMOR_PATCH]
#     MANIFEST    : fox_16.0 | fox_14.1 | fox_12.1
#     BRANCH_TREE : OFOX_New | OFOX | BETA
#     VARIAN      : Default | HyperOS
#     NOMOR_PATCH : 1..10
#  Source yang sudah di-sync dipakai lagi di build berikutnya (tidak sync ulang).
#  Paksa sync ulang:  RESYNC=1 bash build_ofox_ingres.sh
# ==============================================================================

MANIFEST="${1:-fox_16.0}"
TREE_BRANCH="${2:-OFOX_New}"
VARIANT="${3:-Default}"
PATCH_VERSION="${4:-4}"

# ------------------------------------------------------------------ Menu
# Tanpa argumen -> tampilkan menu pilihan. Tekan Enter = pilihan default (*).
pick() {
  # pick "Judul" default_index opsi1 opsi2 ... -> hasil di $PICKED
  local title="$1" def="$2" i=1 ans
  shift 2
  printf '\n\033[1;36m%s\033[0m\n' "$title" >&2
  for o in "$@"; do
    if [ "$i" = "$def" ]; then printf '  %d) %s  *\n' "$i" "$o" >&2; else printf '  %d) %s\n' "$i" "$o" >&2; fi
    i=$((i+1))
  done
  while :; do
    read -r -p "Pilih [1-$#, Enter=$def]: " ans
    [ -z "$ans" ] && ans="$def"
    if [[ "$ans" =~ ^[0-9]+$ ]] && [ "$ans" -ge 1 ] && [ "$ans" -le "$#" ]; then
      PICKED="${!ans}"; PICKED="${PICKED%% *}"; return 0
    fi
    echo "Pilihan tidak valid." >&2
  done
}

if [ $# -eq 0 ] && [ -t 0 ]; then
  printf '\033[1;32m'
  echo '=================================================='
  echo '   OrangeFox Recovery -- ingres (POCO F4 GT)'
  echo '   Build di server + upload ke GoFile  | kingD2N'
  echo '=================================================='
  printf '\033[0m'
  pick "Manifest OrangeFox" 1 "fox_16.0   (Android 16)" "fox_12.1   (Android 12, efek haptic lengkap)" "fox_14.1   (Android 14, eksperimental)"
  MANIFEST="$PICKED"
  pick "Branch device tree ingres" 1 "OFOX_New   (fitur baru: haptic, foto About, dll.)" "OFOX       (versi lama)" "BETA"
  TREE_BRANCH="$PICKED"
  pick "Varian" 1 "Default    (ROM custom AOSP)" "HyperOS    (ROM stock/MIUI/HyperOS)"
  VARIANT="$PICKED"
  pick "Nomor patch (akhiran versi, mis. R12.0_4)" 4 1 2 3 4 5 6 7 8 9 10
  PATCH_VERSION="$PICKED"
  pick "Source OrangeFox" 1 "Pakai source yang sudah ada (cepat)" "Sync ulang dari awal (kalau source rusak / ingin terbaru)"
  [ "$PICKED" = "Sync" ] && export RESYNC=1
  printf '\n\033[1;33mRingkasan:\033[0m %s | tree %s | %s | patch %s | %s\n' \
    "$MANIFEST" "$TREE_BRANCH" "$VARIANT" "$PATCH_VERSION" "$([ "${RESYNC:-0}" = 1 ] && echo 'sync ulang' || echo 'source lama')"
  read -r -p "Mulai build? [Y/n]: " ok
  case "$ok" in n|N|t|T) echo "Dibatalkan."; exit 0 ;; esac
fi

DEVICE_NAME="ingres"
DEVICE_PATH="device/xiaomi/ingres"
DEVICE_TREE_URL="https://github.com/kingD2N/device_xiaomi_ingres_recovery"
SYNC_URL="https://gitlab.com/OrangeFox/sync.git"
MAKEFILE_NAME="twrp_ingres"
MAINTAINER="kingD2N"

# Server dipakai bersama: pakai setengah core saja.
JOBS="${JOBS:-$(( $(nproc) / 2 ))}"
[ "$JOBS" -lt 4 ] && JOBS=4

WORK="${WORK:-$HOME/ofox-ingres}"
SRC="$WORK/$MANIFEST"
STAMP="$(date +%Y%m%d-%H%M)"
LOG="$WORK/build-$MANIFEST-$STAMP.log"

say()  { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[!] %s\033[0m\n' "$*"; }
die()  { printf '\n\033[1;31m[X] %s\033[0m\n' "$*"; upload_log; exit 1; }

case "$MANIFEST" in
  fox_12.1) SYNC_BRANCH=12.1; RELEASES="ap2a ap1a trunk_staging"; HAPTIC_DIR=bootable_recovery ;;
  fox_14.1) SYNC_BRANCH=14.1; RELEASES="ap2a ap1a ap3a ap4a trunk_staging"; HAPTIC_DIR="" ;;
  fox_16.0) SYNC_BRANCH=16.0; RELEASES="bp2a bp1a bp3a bp4a ap2a trunk_staging"; HAPTIC_DIR=bootable_recovery16 ;;
  *) echo "MANIFEST tidak dikenal: $MANIFEST (pilih fox_16.0 / fox_14.1 / fox_12.1)"; exit 1 ;;
esac
case "$VARIANT" in Default|HyperOS) ;; *) echo "VARIAN harus Default atau HyperOS"; exit 1 ;; esac

# ------------------------------------------------------------------ GoFile
gofile_upload() {
  # $1 = file. Cetak link download. Return 1 kalau gagal.
  local f="$1" resp link
  [ -f "$f" ] || return 1
  resp=$(curl -s --retry 3 -F "file=@$f" https://upload.gofile.io/uploadfile) || return 1
  link=$(printf '%s' "$resp" | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin); print(d["data"]["downloadPage"] if d.get("status")=="ok" else "")
except Exception: print("")')
  if [ -n "$link" ]; then
    printf '   %-40s -> %s\n' "$(basename "$f")" "$link"
    echo "$(basename "$f") $link" >> "$WORK/gofile-links.txt"
  else
    warn "Upload $(basename "$f") gagal: $resp"
    return 1
  fi
}
upload_log() {
  [ -f "$LOG" ] || return 0
  say "Upload log build ke GoFile (kirim link/log ini ke Claude kalau gagal)"
  gofile_upload "$LOG" || warn "Log tetap ada di server: $LOG"
}

mkdir -p "$WORK"
exec > >(tee -a "$LOG") 2>&1
say "Build OrangeFox ingres | $MANIFEST | tree $TREE_BRANCH | $VARIANT | patch $PATCH_VERSION | -j$JOBS"
echo "Log lengkap: $LOG"
df -h "$WORK" | tail -1
free -h | head -2

# ------------------------------------------------------------------ 1. Sync
if [ "${RESYNC:-0}" = "1" ] || [ ! -f "$SRC/build/envsetup.sh" ]; then
  say "1/6 Sync source OrangeFox $MANIFEST (pertama kali agak lama)"
  rm -rf "$WORK/sync"
  git clone -q "$SYNC_URL" "$WORK/sync" || die "Clone repo sync gagal"
  echo "Commit sync: $(git -C "$WORK/sync" log -1 --format='%h %cI %s')"
  ok=0
  for i in 1 2 3; do
    ( cd "$WORK/sync" && ./orangefox_sync.sh --branch "$SYNC_BRANCH" --path "$SRC" ) && true
    [ -f "$SRC/build/envsetup.sh" ] && { ok=1; break; }
    warn "Sync belum lengkap (percobaan $i/3), ulang 30 detik lagi..."
    sleep 30
  done
  [ "$ok" = 1 ] || die "Sync gagal: $SRC/build/envsetup.sh tidak ada"
else
  say "1/6 Source $MANIFEST sudah ada -- sync dilewati (RESYNC=1 untuk sync ulang)"
fi

# ------------------------------------------------------------------ 2. Tree + patch
say "2/6 Device tree ingres ($TREE_BRANCH)"
if [ -d "$SRC/$DEVICE_PATH/.git" ]; then
  git -C "$SRC/$DEVICE_PATH" fetch -q origin "$TREE_BRANCH" || die "Fetch device tree gagal"
  git -C "$SRC/$DEVICE_PATH" checkout -q -B "$TREE_BRANCH" "origin/$TREE_BRANCH" || die "Checkout $TREE_BRANCH gagal"
else
  rm -rf "${SRC:?}/${DEVICE_PATH:?}"
  git clone -q -b "$TREE_BRANCH" "$DEVICE_TREE_URL" "$SRC/$DEVICE_PATH" || die "Clone device tree gagal"
fi
echo "Device tree: $(git -C "$SRC/$DEVICE_PATH" log -1 --oneline)"
# File patch ikut di device tree (folder patches/), jadi tidak perlu akses repo OFOX-PROJECT- (private).
PATCH_ROOT="$SRC/$DEVICE_PATH/patches"
[ -d "$PATCH_ROOT" ] || warn "Folder patches/ tidak ada di branch $TREE_BRANCH -- patch haptic dilewati"

# ------------------------------------------------------------------ 3. Perbaikan source
say "3/6 Perbaikan source (sama seperti workflow)"
cd "$SRC" || die "cd $SRC gagal"

if [ "$MANIFEST" != "fox_12.1" ]; then
  DM="$DEVICE_PATH/device.mk"
  if grep -q 'inherit-product, \$(SRC_TARGET_DIR)/product/gsi_keys.mk)' "$DM"; then
    sed -i 's#inherit-product, \$(SRC_TARGET_DIR)/product/gsi_keys.mk)#inherit-product-if-exists, $(SRC_TARGET_DIR)/product/developer_gsi_keys.mk)#' "$DM"
    echo "device.mk: gsi_keys.mk -> developer_gsi_keys.mk"
  fi
  if grep -q '^BOARD_API_LEVEL := ' "$DM" && ! grep -q 'ifndef RELEASE_BOARD_API_LEVEL' "$DM"; then
    sed -i 's/^BOARD_API_LEVEL := \(.*\)$/ifndef RELEASE_BOARD_API_LEVEL\nBOARD_API_LEVEL := \1\nendif/' "$DM"
    echo "device.mk: BOARD_API_LEVEL dibungkus ifndef"
  fi
fi

if [ -d external/se_omapi ] && [ ! -f external/se_omapi/.ingres_stub ]; then
  rm -rf external/se_omapi && mkdir -p external/se_omapi
  printf 'soong_namespace {\n}\n' > external/se_omapi/Android.bp
  touch external/se_omapi/.ingres_stub
  echo "Distub: external/se_omapi"
fi
rm -rf hardware/interfaces/vibrator/aidl/default/example_java_client

for f in bootable/recovery/openaes/src/oaes_lib.c bootable/recovery/openaes/src/isaac/rand.h bootable/recovery/openaes/src/isaac/rand.c; do
  if [ -f "$f" ] && ! grep -q 'Wunknown-warning-option' "$f"; then
    sed -i '1i #pragma clang diagnostic ignored "-Wunknown-warning-option"\n#pragma clang diagnostic ignored "-Wdeprecated-non-prototype"' "$f"
    echo "Dipatch: $f"
  fi
done
MK=bootable/recovery/openaes/Android.mk
if [ -f "$MK" ] && ! grep -q 'ingres-openaes-std' "$MK"; then
  sed -i 's/^\([[:space:]]*\)include \$(BUILD_\(SHARED_LIBRARY\|STATIC_LIBRARY\|EXECUTABLE\))/\1LOCAL_CONLYFLAGS += -std=gnu17 # ingres-openaes-std\n&/' "$MK"
  grep -q 'ingres-openaes-std' "$MK" && echo "Dipatch: openaes -> -std=gnu17" || warn "openaes/Android.mk: pola include tidak ketemu"
fi

# Haptic: menu Haptic feedback (patch yudharn)
HAPTIC_MENU="Getar biasa"
if [ -n "$HAPTIC_DIR" ]; then
  for P in "$PATCH_ROOT/$HAPTIC_DIR"/*.patch; do
    [ -f "$P" ] || continue
    if git -C bootable/recovery apply -R --check "$P" 2>/dev/null; then
      echo "$(basename "$P") sudah terpasang"; HAPTIC_MENU="Menu Haptic feedback"
    elif git -C bootable/recovery apply --check "$P" 2>/dev/null; then
      git -C bootable/recovery apply "$P" && { echo "Diterapkan: $(basename "$P")"; HAPTIC_MENU="Menu Haptic feedback"; }
    else
      warn "$(basename "$P") tidak cocok dengan bootable/recovery -- dilewati"
    fi
  done
fi

# Haptic: motor awinic ingres di HAL qcom (hanya layout lama, fox_12.1)
HAPTIC_HAL="Xiaomi"
V=vendor/qcom/opensource/vibrator; F="$V/aidl/Vibrator.cpp"
if [ -f "$F" ]; then
  grep -q '"awinic_haptic"' "$F" || sed -i '0,/strcmp(name, "qti-haptics")/s//strcmp(name, "qti-haptics") \&\& strcmp(name, "awinic_haptic") \&\& strcmp(name, "aw8697_haptic")/' "$F"
  if grep -q '"awinic_haptic"' "$F"; then touch "$V/.ingres_awinic"; HAPTIC_HAL="qcom (efek) + Xiaomi"; fi
fi
echo "Haptic: $HAPTIC_MENU | HAL $HAPTIC_HAL"

# Foto maintainer di About
IMG="$DEVICE_PATH/misc/kingD2N.png"
DST="bootable/recovery/gui/theme/portrait_hdpi/images/Default/About/maintainer.png"
if [ -f "$IMG" ] && [ -f "$DST" ] && file "$IMG" | grep -q 'PNG image data, 192 x 192'; then
  cp -f "$IMG" "$DST" && echo "Foto maintainer dipasang"
fi

# ------------------------------------------------------------------ 4. lunch
say "4/6 lunch"
# shellcheck disable=SC1091
source build/envsetup.sh >/dev/null
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL=C
export OF_MAINTAINER="$MAINTAINER"
export FOX_MAINTAINER_PATCH_VERSION="$PATCH_VERSION"
export FOX_VARIANT="$VARIANT"
if [ "$VARIANT" = "Default" ]; then export FOX_VANILLA_BUILD=1; else export FOX_VANILLA_BUILD=0; fi
export OF_SCREEN_H=2400
[ -f "$SRC/$IMG" ] && export OF_MAINTAINER_AVATAR="$SRC/$IMG"
unset OUT_DIR

LUNCH_OK=0
if [ "$MANIFEST" = "fox_12.1" ] && lunch "${MAKEFILE_NAME}-eng"; then
  LUNCH_OK=1
else
  for REL in $RELEASES; do
    echo "-- lunch ${MAKEFILE_NAME}-${REL}-eng"
    if lunch "${MAKEFILE_NAME}-${REL}-eng"; then LUNCH_OK=1; break; fi
  done
  [ "$LUNCH_OK" = 1 ] || { lunch "${MAKEFILE_NAME}-eng" && LUNCH_OK=1; }
fi
[ "$LUNCH_OK" = 1 ] || die "Semua percobaan lunch gagal"

# ------------------------------------------------------------------ 5. Build
say "5/6 Build recovery (-j$JOBS)"
START=$(date +%s)
mka adbd recoveryimage -j"$JOBS"
RC=$?
echo "Lama build: $(( ($(date +%s) - START) / 60 )) menit"
[ "$RC" -eq 0 ] || die "Build GAGAL (exit $RC). Cari baris 'FAILED:' di log."

# ------------------------------------------------------------------ 6. Upload
say "6/6 Upload hasil ke GoFile"
OUT="$SRC/out/target/product/$DEVICE_NAME"
RIMG="$OUT/recovery.img"
RZIP=$(grep -a -m1 '^Recovery zip:' "$LOG" 2>/dev/null | sed 's/^Recovery zip:[[:space:]]*//')
[ -f "$RZIP" ] || RZIP=$(ls -t "$OUT"/OrangeFox-*.zip 2>/dev/null | head -n1)
[ -f "$RIMG" ] || [ -f "$RZIP" ] || die "Build selesai tapi recovery.img / zip OrangeFox tidak ditemukan di $OUT"
: > "$WORK/gofile-links.txt"
[ -f "$RIMG" ] && { cp -f "$RIMG" "$WORK/recovery-$MANIFEST-$VARIANT-$STAMP.img"; gofile_upload "$WORK/recovery-$MANIFEST-$VARIANT-$STAMP.img"; }
[ -f "$RZIP" ] && gofile_upload "$RZIP"
upload_log

say "SELESAI ✓  ($MANIFEST | $VARIANT | Haptic: $HAPTIC_MENU, HAL $HAPTIC_HAL)"
echo "Link GoFile juga tersimpan di: $WORK/gofile-links.txt"
