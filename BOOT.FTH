\ ============================================================
\ BOOT.FTH  —  Epona OS boot sequence
\ ============================================================
\ Se lance avec :  exec BOOT.FTH
\ Ou depuis le shell :  require BOOT.FTH
\ ============================================================

cr
cr ." ╔══════════════════════════════════════════╗"
cr ." ║        Epona OS  —  EponaForth           ║"
cr ." ╚══════════════════════════════════════════╝"
cr

\ ─── Charger la bibliothèque standard ───────────────────────
cr ." [*] Chargement des bibliotheques..." cr
require STDLIB.FTH
require FIXED.FTH
require MUTEX.FTH
cr ." [✓] Bibliotheques chargees" cr

\ ─── GPU ─────────────────────────────────────────────────────
cr ." [*] Detection GPU..." cr
[defined] gpu:init [if]
  gpu:init if
    gpu:info
  else
    cr ." [!] GPU: fallback software" cr
  then
[then]

\ ─── Audio HDA ───────────────────────────────────────────────
cr ." [*] Detection audio HDA..." cr
[defined] hda-init [if]
  hda-init if
    hda-info
  else
    cr ." [!] Audio: aucun codec detecte" cr
  then
[then]

\ ─── Réseau ──────────────────────────────────────────────────
cr ." [*] Initialisation reseau..." cr
[defined] net:init [if]
  net:init if
    cr ." [*] DHCP..." cr
    net:dhcp if
      ." [✓] Reseau: " net:stack-info
    else
      cr ." [!] DHCP: echec (IP statique necessaire)" cr
    then
  else
    cr ." [!] Reseau: pas de carte detectee" cr
  then
[then]

\ ─── USB ─────────────────────────────────────────────────────
cr ." [*] Initialisation USB..." cr
[defined] xhci-init [if]
  xhci-init if
    ." [✓] USB: XHCI OK" cr
  else
    ." [!] USB: echec" cr
  then
[then]

\ ─── Stockage ────────────────────────────────────────────────
cr ." [*] Detection stockage..." cr
[defined] nvme:init [if]
  nvme:init if
    ." [✓] NVMe detecte" cr
  else
    ." [ ] NVMe: absent" cr
  then
[then]

[defined] ahci:init [if]
  ahci:init if
    ." [✓] AHCI detecte" cr
  else
    ." [ ] AHCI: absent" cr
  then
[then]

\ ─── Souris USB ─────────────────────────────────────────────
[defined] xhci-souris? [if]
  xhci-souris? if
    ." [✓] Souris USB detectee" cr
  then
[then]

\ ─── I2C Touchpad ───────────────────────────────────────────
[defined] i2c-touchpad-init [if]
  i2c-touchpad-init if
    ." [✓] Touchpad I2C detecte" cr
  then
[then]

\ ─── Charger le programme principal ─────────────────────────
cr
[undefined] principal [if]
  cr ." [!] Aucun mot PRINCIPAL trouve." cr
  cr ."     Creer :  : principal begin .\" tick\" cr 1000 ms again ;" cr
  cr ."     Puis :   principal" cr
[else]
  cr ." [*] Lancement de PRINCIPAL..." cr
  principal
[then]

cr
cr ." Epona OS pret." cr
