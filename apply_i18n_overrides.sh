#!/bin/bash
# Apply OpenPLC_Editor locale/UI overrides on top of the editor submodule.
set -euo pipefail

OPENPLC_DIR="$(dirname "$(readlink -f "$0")")"
SRC_PO="$OPENPLC_DIR/i18n/zh_CN/Beremiz_zh_CN.po"
DST_PO="$OPENPLC_DIR/editor/i18n/Beremiz_zh_CN.po"
DST_MO="$OPENPLC_DIR/editor/locale/zh_CN/LC_MESSAGES/Beremiz.mo"
PATCH="$OPENPLC_DIR/patches/0001-remove-check-for-updates.patch"

if [ ! -d "$OPENPLC_DIR/editor" ]; then
    echo "editor directory not found; run submodule init first" >&2
    exit 1
fi

if [ -f "$SRC_PO" ]; then
    mkdir -p "$(dirname "$DST_PO")" "$(dirname "$DST_MO")"
    cp "$SRC_PO" "$DST_PO"

    if command -v msgfmt >/dev/null 2>&1; then
        msgfmt -o "$DST_MO" "$SRC_PO"
    else
        SRC_MO="$OPENPLC_DIR/i18n/zh_CN/LC_MESSAGES/Beremiz.mo"
        if [ -f "$SRC_MO" ]; then
            cp "$SRC_MO" "$DST_MO"
        else
            echo "msgfmt not found and no prebuilt Beremiz.mo override available" >&2
            exit 1
        fi
    fi
    echo "Applied Simplified Chinese (zh_CN) translation overrides"
fi

if [ -f "$PATCH" ]; then
    # Apply only once (skip if already patched).
    if grep -q 'Check for updates' "$OPENPLC_DIR/editor/BeremizIDE.py" 2>/dev/null; then
        patch -p1 -d "$OPENPLC_DIR" --forward --reject-file=- < "$PATCH"
        echo "Applied UI patch: remove Check for updates menu"
    else
        echo "UI patch already applied (Check for updates menu absent)"
    fi
fi
