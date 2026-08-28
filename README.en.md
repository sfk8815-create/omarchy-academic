# Omarchy Academic (学研版)

A customization layer on top of [Omarchy](https://omarchy.org/) 4.0.1 that turns a stock Omarchy install into a **Chinese-first academic/research environment** for researchers, university students, and teachers.

## Highlights

- `zh_CN.UTF-8` locale + China timezone
- fcitx5 + Rime input method with the rime-ice (雾凇拼音) scheme
- CJK font fallback for JetBrainsMono and Chromium/Electron apps
- Chinese rendering in alacritty, foot, kitty, and ghostty terminals
- Academic stack: Zotero, Obsidian, Zettlr, Xournal++, LibreOffice/WPS, Tesseract Chinese OCR, Pandoc, TeX Live
- Optional Chinese apps: WeChat, DingTalk, Feishu, WPS Office
- Optional hardware modules: Apple keyboard, HiDPI
- One-command install/uninstall, `sync.sh`, and CI checks

## Quick start

On a fresh Omarchy 4.0.1 system:

```bash
git clone https://github.com/sfk8815-create/omarchy-academic.git
cd omarchy-academic
./install.sh
```

See [docs/install.md](docs/install.md) (Chinese) for details. The repo contains no personal data or secrets.
