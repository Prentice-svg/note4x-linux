#!/usr/bin/env bash
set -euo pipefail

DISTRO="debian-bookworm"
KERNEL_REPO="https://github.com/msm8953-mainline/linux.git"
KERNEL_BRANCH="master"
DTB="qcom/msm8953-xiaomi-mido.dtb"

case "${1:---plan}" in
  --plan)
    echo "TARGET=mido"
    echo "DISTRO=${DISTRO}"
    echo "KERNEL_REPO=${KERNEL_REPO}"
    echo "KERNEL_BRANCH=${KERNEL_BRANCH}"
    echo "DTB=${DTB}"
    ;;
  --preflight)
    command -v fastboot >/dev/null
    count="$(fastboot devices | awk 'NF >= 2 {n++} END {print n+0}')"
    echo "FASTBOOT_DEVICE_COUNT=${count}"
    if [[ "${count}" -gt 0 ]]; then
      echo "PRODUCT=$(fastboot getvar product 2>&1 | awk -F': ' '/product:/{print $2; exit}')"
    else
      echo "PRODUCT=NOT_CONNECTED"
    fi
    ;;
  *)
    echo "usage: $0 [--plan|--preflight]" >&2
    exit 2
    ;;
esac
