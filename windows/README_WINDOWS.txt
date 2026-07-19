OpenPLC Editor - Simplified Chinese (zh_CN) Windows Test Package
================================================================

This is NOT a full Windows installer rebuild.
Official Windows binaries are only published by Autonomy Logic.
This package overlays our Chinese UI changes onto an existing install.

What you get
------------
- Complete zh_CN translation catalog (including 教程与示例)
- Removal of File -> Check for updates...

Install / test steps
--------------------
1. Install official OpenPLC Editor for Windows from:
   https://autonomylogic.com

2. Find the install folder. Typical locations:
   - %USERPROFILE%\OpenPLC_Editor
   - C:\Users\<you>\OpenPLC_Editor
   It must contain editor\Beremiz.py

3. Copy this whole package folder into that install folder
   (or keep it anywhere and pass the install path).

4. Double-click apply_zh_cn.cmd
   Or from Command Prompt:
     apply_zh_cn.cmd "C:\Users\<you>\OpenPLC_Editor"

5. Set Windows display language to 中文(简体) / Chinese (Simplified),
   then fully quit and restart OpenPLC Editor.

6. Check:
   - Menus/panels are Chinese
   - File menu contains 教程与示例
   - File menu does NOT contain Check for updates...

Restore official files
----------------------
Reinstall OpenPLC Editor, or restore editor\ from a backup made before applying.

Source
------
Built from fork branch cursor/finish-zh-cn-translation-5063
PR: https://github.com/wangqq1981-hub/OpenPLC_Editor/pull/2
