Bijwerken van R als gebruiker
================
Thierry Onkelinx
30 september 2016

Na de eerste installatie
------------------------

Bij een nieuwe `R` installatie hoeft de gebruiker geen bijkomende stappen te ondernemen.

Na elke upgrade
---------------

Voor onderstaande instructies uit telkens een nieuwe `R` versie geïnstalleerd werd. Je kan dit, indien gewenst, ook frequenter uitvoeren.

### Windows

1.  Zorg dat de computer verbonden is met het internet.
2.  Zorg dat er geen enkele `R` sessie actief is op de computer.
3.  Start `R x64` via het menu start.
4.  Tik het commando `update.packages(ask = FALSE, checkBuilt = TRUE)` gevolgd door enter.
5.  Er zullen nu packages waarvan een nieuwe versie beschikbaar is gedownload en geïnstalleerd worden. Dit duurt een hele poos, afhankelijk van het aantal te upgraden packages.
6.  Wacht tot de installatie volledig afgelopen is.
7.  Tik vervolgens het commando `q()` gevolgd door enter. `R` zal nu afgesloten worden.

### Linux

1.  Zorg dat de computer verbonden is met het internet.
2.  Zorg dat er geen enkele `R` sessie actief is op de computer.
3.  Open een terminal venster (`Ctrl + Alt + T`).
4.  Voer het commando `Rscript -e 'update.packages(ask = FALSE, checkBuilt = TRUE)'` uit.
5.  Er zullen nu packages waarvan een nieuwe versie beschikbaar is gedownload en geïnstalleerd worden. Dit duurt een hele poos, afhankelijk van het aantal te upgraden packages.
6.  Wacht tot de installatie volledig afgelopen is.
7.  Sluit de terminal met `exit`.
