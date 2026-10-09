#!/bin/sh
# Regenerates the localization classes. Each feature area keeps its own ARB
# files in lib/l10n/<area>/ and gets its own <Area>L10n class.
#   tool/gen_l10n.sh            -> every area
#   tool/gen_l10n.sh chat       -> one area
set -e
cd "$(dirname "$0")/.."
areas="${*:-$(ls lib/l10n)}"
for area in $areas; do
  class="$(printf '%s' "$area" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')L10n"
  flutter gen-l10n \
    --arb-dir "lib/l10n/$area" \
    --template-arb-file app_en.arb \
    --output-dir "lib/l10n/$area/gen" \
    --output-localization-file "${area}_l10n.dart" \
    --output-class "$class" \
    --no-nullable-getter
done
