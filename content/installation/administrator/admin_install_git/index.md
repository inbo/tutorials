---
title: "Git installation"
description: "Installation instructions for Git (in Dutch). Git is a free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency."
categories: ["installation"]
tags: ["git", "version control", "installation"]
---

## Windows

De installatiebestanden zijn beschikbaar via http://git-scm.com/downloads

1. Installeer eerst `notepad++`.
1. Voer het installatiebestand uit en klik _Ja_.
1. Welkom bij de installatie: klik op _Next_.
1. Aanvaard de licentievoorwaarden door _Next_ te klikken.
1. Installeer git in de voorgestelde standaard directory.
1. Gebruik de standaard componenten door _Next_ te klikken.
1. Klik _Next_ om de menu map in te stellen.
1. Kies `Notepad++` als editor.
1. Kies `use Git from the command line` en klik _Next_.
1. `Use OpenSSL library` en klik _Next_.
1. Kies `Checkout Windows-style, commit Unix-style line endings` en klik _Next_
1. Kies `use Windows' default console window` en klik _Next_
1. Kies `Default` en klik _Next_.
1. Gebruik de standaard door _Next_ te klikken.
1. Gebruik de standaard door _Install_ te klikken.
1. Vink alles uit en klik op _Next_.
1. Download [gitconfig](gitconfig).
Bewaar het bestand als `.gitconfig` (bestandsnaam start met een punt) in `c:/users/username`.
Zorg dat de gebruiker toegangsrechten heeft tot dit bestand.

### Afwijkingen t.o.v. default installatie

- `Notepad++` als editor
- `use Windows' default console window`
- `.gitconfig` downloaden en bewaren in de map van de gebruiker (met toegangsrechten voor de gebruiker)

## Ubuntu

```
sudo apt-get update
sudo apt-get install git
```
