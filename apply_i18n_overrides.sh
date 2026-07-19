#!/bin/bash
# Apply OpenPLC_Editor locale overrides on top of the editor submodule.
set -euo pipefail

OPENPLC_DIR="$(dirname "$(readlink -f "$0")")"
SRC_PO="$OPENPLC_DIR/i18n/zh_CN/Beremiz_zh_CN.po"
DST_PO="$OPENPLC_DIR/editor/i18n/Beremiz_zh_CN.po"
DST_MO="$OPENPLC_DIR/editor/locale/zh_CN/LC_MESSAGES/Beremiz.mo"

if [ ! -f "$SRC_PO" ]; then
    echo "i18n override not found: $SRC_PO" >&2
    exit 1
fi

if [ ! -d "$OPENPLC_DIR/editor" ]; then
    echo "editor directory not found; run submodule init first" >&2
    exit 1
fi

mkdir -p "$(dirname "$DST_PO")" "$(dirname "$DST_MO")"
cp "$SRC_PO" "$DST_PO"

if command -v msgfmt >/dev/null 2>&1; then
    msgfmt -o "$DST_MO" "$SRC_PO"
else
    # Fallback for environments without gettext tools.
    SRC_MO="$OPENPLC_DIR/i18n/zh_CN/LC_MESSAGES/Beremiz.mo"
    if [ -f "$SRC_MO" ]; then
        cp "$SRC_MO" "$DST_MO"
    else
        echo "msgfmt not found and no prebuilt Beremiz.mo override available" >&2
        exit 1
    fi
fi

echo "Applied Simplified Chinese (zh_CN) translation overrides"
