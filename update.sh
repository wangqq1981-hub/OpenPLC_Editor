#!/bin/bash
if [ -d "./new_editor" ]
then
    rm -Rf new_editor
fi
if [ -d "./OpenPLC_Editor" ]
then
    rm -Rf OpenPLC_Editor
fi
git clone https://github.com/thiagoralves/OpenPLC_Editor
if [ -d "./OpenPLC_Editor/editor" ]
then
    mv "./OpenPLC_Editor/editor" ./new_editor
    mv "./OpenPLC_Editor/matiec/lib" ./new_lib
    cp ./OpenPLC_Editor/revision ./
    rm -Rf OpenPLC_Editor
    if [ -f "./i18n/zh_CN/Beremiz_zh_CN.po" ]
    then
        # Keep pending editor update in sync; launcher also reapplies overrides.
        mkdir -p ./new_editor/i18n ./new_editor/locale/zh_CN/LC_MESSAGES
        cp ./i18n/zh_CN/Beremiz_zh_CN.po ./new_editor/i18n/Beremiz_zh_CN.po
        cp ./i18n/zh_CN/LC_MESSAGES/Beremiz.mo ./new_editor/locale/zh_CN/LC_MESSAGES/Beremiz.mo
    fi
    echo "Update applied successfully"
else
    echo "Error cloning from repository!"
fi
