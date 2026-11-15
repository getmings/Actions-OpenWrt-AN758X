#!/bin/bash
# =====================================================================
# 安装 airoha 内核补丁 (947 SRAM 拥塞剖面, 上游 pbs05/ponwrt PR #64 draft)
#
# 执行时机: feeds install 之后、diy-part1 之前; cwd = openwrt 源码根。
# 症状: lan2/lan3 互联网方向卡 300-500M (AN7581, 仅 airoha_is_7581 生效)
# 注意: 两个补丁有依赖, 必须 01 -> 02 顺序 (文件名前缀已保证字母序)
# 失败策略: FATAL 退出, 不产出"以为带了补丁其实没带"的固件。
# =====================================================================
set -u
PATCH_ROOT="${GITHUB_WORKSPACE:-$(cd "$(dirname "$0")/.." && pwd)}/patches/airoha-kernel"
DEST=target/linux/airoha/patches-6.18

if [ ! -d "$DEST" ]; then
  echo "FATAL: 找不到 $DEST (源码不是 6.18 内核 / target/linux/airoha 布局变了?)"
  ls -1 target/linux/airoha/ 2>/dev/null || true
  exit 1
fi
for p in 947-01-net-airoha-initialize-lan-sram-congestion.patch \
         947-02-net-airoha-initialize-wan-sram-congestion.patch; do
  if [ ! -f "$PATCH_ROOT/$p" ]; then
    echo "FATAL: 缺少 $PATCH_ROOT/$p"; exit 1
  fi
  cp "$PATCH_ROOT/$p" "$DEST/$p"
  echo "已安装内核补丁: $DEST/$p"
done
echo "=== 947 SRAM 拥塞剖面已注入 ==="
exit 0
