---
title: "Rtools installation"
description: "Installation instructions for Rtools (in Dutch). Rtools is a collection of resources for building packages for R under Microsoft Windows."
date: 2017-10-18T00:30:16+02:00
categories: ["installation"]
tags: ["r", "windows", "installation"]
---

## Windows

### Installatie en upgrade

De installatiebestanden zijn beschikbaar via [cloud.r-project.org](https://cloud.r-project.org/bin/windows/Rtools/).
Kies de 64-bit versie van de installer.

Bij een upgrade dient eerst de vorige versie te worden verwijderd.

1. Klik _Ja_.
1. Kies `C:\rtools40` (standaard) als installatiemap en klik _Next_.
1. Laat alles aangevinkt en klik _Next_.
1. Klik _Install_.
1. Klik _Finish_.
1. Wijzing `PATH` naar `PATH="${RTOOLS40_HOME}\usr\bin;${PATH}"`.
1. Start R en controleer of `Sys.which("make")` verwijst naar `"C:\\rtools40\\usr\\bin\\make.exe"`.

### Afwijkingen t.o.v. default installatie

- Wijzig de systeemvariabele `PATH` naar `PATH="${RTOOLS40_HOME}\usr\bin;${PATH}"`
