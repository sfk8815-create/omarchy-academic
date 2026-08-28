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
- Optional community modules: Chinese UI localization, lunar calendar, China mirrors + archlinuxcn
- Academic/desktop modules: sovena literature workflow, MCP Cockpit, Open Science Desktop, Aether theming
- One-command install/uninstall, `sync.sh`, and CI checks

## Quick start

On a fresh Omarchy 4.0.1 system:

```bash
git clone https://github.com/sfk8815-create/omarchy-academic.git
cd omarchy-academic
./install.sh
```

Community modules (sources and licenses in [docs/resources.md](docs/resources.md)):

```bash
./install.sh --with-zh-ui       # Chinese UI localization for Omarchy (MIT)
./install.sh --with-lunar       # Chinese lunar calendar bar widget (MIT)
./install.sh --with-cn-mirrors  # China mirrors + archlinuxcn repository
./install.sh --with-desktop     # Aether theming + Open Science Desktop
./install.sh --with-sovena      # sovena literature workflow (Zotero → semantic search)
./install.sh --with-mcp-cockpit # unified MCP gateway cockpit
```

See [docs/install.md](docs/install.md) (Chinese) for details. The repo contains no personal data or secrets.
