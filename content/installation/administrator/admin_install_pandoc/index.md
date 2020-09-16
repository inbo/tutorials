---
title: "Pandoc installation"
description: "Installation instructions for pandoc (in Dutch). If you need to convert files from one markup format into another, pandoc is your swiss-army knife. Pandoc can convert documents in (several dialects of) Markdown, reStructuredText, textile, HTML, DocBook, LaTeX, MediaWiki markup, TWiki markup, TikiWiki markup, Creole 1.0, Vimwiki markup, OPML, Emacs Org-Mode, Emacs Muse, txt2tags, Microsoft Word docx, LibreOffice ODT, EPUB, or Haddock markup."
date: 2017-10-18T00:28:40+02:00
categories: ["installation"]
tags: ["pandoc", "markdown", "installation"]
---

## Windows

Pandoc wordt automatisch geïnstalleerd als je RStudio installeert.

## Ubuntu

1. Kijk op https://github.com/jgm/pandoc/releases wat de laatste versie is.
1. Pas het versienummer in onderstaande code aan en voer ze uit in een terminalvenster

```
wget https://github.com/jgm/pandoc/releases/download/1.19/pandoc-1.19-1-amd64.deb
sudo dpkg -i pandoc-1.19-1-amd64.deb
rm pandoc-1.19-1-amd64.deb
```
