---
title: "LaTeX"
date: 2017-10-18T00:29:35+02:00
description: "Installation instructions for LaTeX compilers (in Dutch). LaTeX is a high-quality typesetting system; it includes features designed for the production of technical and scientific documentation."
---

## Windows

De installatiebestanden zijn beschikbaar via http://miktex.org/download

1. Start de installer en klik op _Uitvoeren_.
1. Aanvaard de voorwaarden en klik op _Volgende_
1. Selecteer _Anyone who uses this computer_ en klik op _volgende_.
1. In het veld _Install MikTeX to_ vul je `C:\Program files\MikTeX` in en klik op _volgende_.
1. Wijzig _Install missing packages on-the-fly_ naar `Yes` en klik op _volgende_.
1. Klik op _Start_.
1. Klik op _volgende_.
1. Klik op _close_.
1. Ga in het _Start_ menu naar de _MikTex_ map.
1. Start _Update (admin)_ in de submap _Maintainance (admin)_.
1. Selecteer _remote package repository_ en _nearest package repository_ en klik tenslotte op _Volgende_.
1. Klik op _Volgende_.
1. Klik op _Volgende_.

### Afwijkingen t.o.v. default installatie

- _Install missing packages on-the-fly_: `Yes`

## Ubuntu

### Minimale installatie

```
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    lmodern \
    qpdf \
    texlive-fonts-recommended \
    texlive-humanities \
    texlive-latex-extra \
    texinfo
cd /usr/share/texlive/texmf-dist
sudo wget http://mirrors.ctan.org/install/fonts/inconsolata.tds.zip
sudo unzip inconsolata.tds.zip
sudo rm inconsolata.tds.zip
sudo echo "Map zi4.map" >> /usr/share/texlive/texmf-dist/web2c/updmap.cfg
sudo mktexlsr
sudo updmap-sys
cd ~
```
