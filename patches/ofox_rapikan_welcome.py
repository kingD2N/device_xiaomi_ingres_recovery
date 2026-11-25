#!/usr/bin/env python3
# Tidies the OrangeFox welcome text (Indonesian language) so every ":" sits in
# the same column, and shortens lines that wrapped on the ingres screen.
#
#   [Rilis]      : R12.0_6
#   [Tgl Build]  : Tue Nov 24 20:04:09 2026
#   * Perangkat:   POCO F4 GT (ingres)
#
# Usage: python3 ofox_rapikan_welcome.py <path to bootable/recovery>
# Idempotent. If a key/file is missing it only prints a warning.

import os
import re
import sys

LABEL_W = 12   # width of the longest label "[Basis Kode]"/"[Pengaturan]"
BULLET_W = 13  # value starts in the same column as the [..] lines


def kv(label, value):
    return f"{label.ljust(LABEL_W)} : {value}"


def bullet(label, value):
    return f"* {(label + ':').ljust(BULLET_W)}{value}"


ID_STRINGS = {
    "fox_release": kv("[Rilis]", "{1}"),
    "fox_variant": kv("[Varian]", "{1}"),
    "fox_codebase": kv("[Basis Kode]", "{1}, {2}"),
    "fox_settings": kv("[Pengaturan]", "{1}"),
    "fox_misc": kv("[Lainnya]", "{1}"),
    "fox_build_date": kv("[Tgl Build]", "{1}"),
    "fox_build_type": kv("[Tipe Build]", "{1}"),
    "fox_build_type_unofficial": kv("[Tipe Build]", "Tidak resmi (tanpa dukungan)"),
    "fox_support": kv("[Dukungan]", "{1}"),
    "fox_nosupport": kv("[Dukungan]", "Tanpa dukungan resmi"),
    "fox_downloads": kv("[Unduhan]", "{1}"),
    "fox_faq": kv("[Panduan]", "{1}"),
    "fox_platform": bullet("Platform", "{1}"),
    "fox_display": bullet("Tampilan", "{1}"),
    "fox_device": bullet("Perangkat", "{1} ({2})"),
    "fox_dynamic_yes": bullet("Dinamis", "ya"),
    "fox_dynamic_no": bullet("Dinamis", "tidak"),
    "fox_boot_slot": bullet("Slot Boot", "{1}"),
    "fox_vab_yes": bullet("Virtual_AB", "ya"),
    "fox_vab_no": bullet("Virtual_AB", "tidak"),
    "fox_kernel": bullet("Kernel", "{1}"),
    "fox_fingerprint": bullet("Sidik Jari", "{1}"),
}


def warn(msg):
    print(f"[PERINGATAN] rapikan_welcome: {msg}")


def patch_lang(path):
    try:
        s = open(path, encoding="utf-8").read()
    except OSError as e:
        warn(f"tidak bisa baca {path}: {e}")
        return
    n = 0
    for key, val in ID_STRINGS.items():
        pat = re.compile(r'(<string name="%s">)(.*?)(</string>)' % re.escape(key))
        if not pat.search(s):
            warn(f"{key} tidak ada di {os.path.basename(path)}")
            continue
        s, c = pat.subn(lambda m: m.group(1) + val + m.group(3), s, count=1)
        n += c
    open(path, "w", encoding="utf-8").write(s)
    print(f"rapikan_welcome: {n} teks dirapikan di {os.path.basename(path)}")


def patch_branch(path):
    # "[Branch]" is printed with gui_print (not translated), align it as well
    try:
        s = open(path, encoding="utf-8").read()
    except OSError:
        return
    new = 'gui_print("%s : %%s\\n", OF_CURRENT_BRANCH)' % "[Branch]".ljust(LABEL_W)
    s2, c = re.subn(r'gui_print\("\[Branch\] *: *%s\\n", *OF_CURRENT_BRANCH\)',
                    lambda m: new, s)
    if c:
        if s2 != s:
            open(path, "w", encoding="utf-8").write(s2)
        print("rapikan_welcome: baris [Branch] dirapikan")
    else:
        warn("baris [Branch] tidak ketemu (dilewati)")


def main():
    if len(sys.argv) != 2:
        print("usage: ofox_rapikan_welcome.py <bootable/recovery>")
        return 1
    root = sys.argv[1].rstrip("/")
    langs = [os.path.join(root, d, "id_ID.xml") for d in
             ("gui/theme/common/languages", "gui/theme/extra-languages/languages")]
    found = [p for p in langs if os.path.isfile(p)]
    if not found:
        warn("id_ID.xml tidak ditemukan")
    for p in found:
        patch_lang(p)
    patch_branch(os.path.join(root, "twrp-functions.cpp"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
