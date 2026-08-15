#!/usr/bin/env bash
set -euo pipefail

LK2ND="mido-lk2nd-official-modified.img"
BOOT="mido-debian-7.1.3-modified-boot.img"
ROOTFS="debian-trixie-arm64-mido-rootfs-modified.sparse.img"
COMBINED_BOOT="mido-debian-7.1.3-stock-fastboot-combined-boot.img"
MANIFEST="mido-flash-sha256.txt"

usage() {
  echo "usage: $0 --check|--flash" >&2
  exit 2
}

check_files() {
  command -v fastboot >/dev/null
  command -v sha256sum >/dev/null
  for file in "$LK2ND" "$BOOT" "$ROOTFS" "$COMBINED_BOOT" "$MANIFEST"; do
    [[ -f "$file" ]] || { echo "missing: $file" >&2; exit 1; }
  done
  sha256sum -c "$MANIFEST"
}

product_of() {
  fastboot -s "$1" getvar product 2>&1 | awk -F': ' '/^product:/{print $2; exit}'
}

find_target() {
  local serial product
  local -a targets=()
  while read -r serial _; do
    [[ -n "$serial" ]] || continue
    product="$(product_of "$serial" || true)"
    if [[ "$product" == "mido" || "$product" == "lk2nd-msm8953" ]]; then
      targets+=("$serial:$product")
    fi
  done < <(fastboot devices)
  [[ ${#targets[@]} -eq 1 ]] || {
    echo "expected exactly one mido/lk2nd-msm8953 target, found ${#targets[@]}" >&2
    exit 1
  }
  printf '%s\n' "${targets[0]}"
}

flash_target() {
  local target serial product unlocked
  target="$(find_target)"
  serial="${target%%:*}"
  product="${target#*:}"
  if [[ "$product" == "mido" ]]; then
    fastboot -s "$serial" flash userdata "$ROOTFS"
    fastboot -s "$serial" flash boot "$COMBINED_BOOT"
    fastboot -s "$serial" reboot
    echo "FLASH_COMPLETE"
    return 0
  fi

  unlocked="$(fastboot -s "$serial" getvar unlocked 2>&1 | awk -F': ' '/^unlocked:/{print $2; exit}')"
  [[ "$unlocked" == "yes" || "$unlocked" == "true" ]] || {
    echo "lk2nd target is not unlocked" >&2
    exit 1
  }
  fastboot -s "$serial" flash lk2nd "$LK2ND"
  fastboot -s "$serial" flash userdata "$ROOTFS"
  fastboot -s "$serial" flash boot "$BOOT"
  fastboot -s "$serial" reboot
  echo "FLASH_COMPLETE"
}

[[ $# -eq 1 ]] || usage
case "$1" in
  --check) check_files ;;
  --flash) check_files; flash_target ;;
  *) usage ;;
esac
