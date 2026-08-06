\ ══════════════════════════════════════════════════════════
\ AMD-xHCI-USB3.FTH
\ Marque:   AMD
\ Ref:      USB 3.1/3.2 xHCI Controller (Cezanne)
\ Vendor:   1022h (AMD)
\ Device:   15E0h (USB 3.1 xHCI)
\ Ports:    4x USB 3.1 Gen1 (5 Gbps) + 4x USB 2.0
\ Standard: eXtensible Host Controller Interface 1.2
\ Primitives: xhci-init, usb:devices, usb:control,
\             usb:read, usb:write, xhci-souris,
\             xhci-souris?, usb:msd-probe, usb:msd-info
\ ══════════════════════════════════════════════════════════

\ --- Scan ---
: amd-xhci-usb3-scan
  cr
  cr ." === AMD USB 3.1 xHCI ==="
  cr ."  Marque:      AMD"
  cr ."  Ref:         USB 3.1 xHCI (Cezanne)"
  cr ."  Vendor ID:   1022h"
  cr ."  Device ID:   15E0h"
  cr ."  Standard:    xHCI 1.2"
  cr ."  Ports:       4x USB 3.1 Gen1 (5 Gbps)"
  cr ."               4x USB 2.0"
  cr
  xhci-init if
    cr ."  xHCI INIT:   OK"
  else
    cr ."  xHCI INIT:   ÉCHEC"
  then
  cr
  cr ."  Périphériques détectés:"
  usb:devices
  cr
;

\ --- Souris ---
: amd-xhci-mouse
  cr
  cr ." === AMD USB 3.1 — Souris ==="
  xhci-souris? if
    cr ."  Souris DETECTÉE"
    xhci-souris
    cr ."  DX: " u. cr ."  DY: " u. cr ."  BTN: " u. cr
  else
    cr ."  Aucune souris USB"
  then
  cr
;

\ --- Périphériques de masse ---
: amd-xhci-msd
  cr
  cr ." === AMD USB 3.1 — Périphériques de masse ==="
  usb:msd-probe
  cr ."  Nombre de disques: " u. cr
;

\ --- Init ---
: amd-xhci-usb3-init
  cr
  cr ." --- AMD USB 3.1 INIT ---"
  amd-xhci-usb3-scan
  amd-xhci-mouse
  amd-xhci-msd
  cr ." AMD USB 3.1 init OK." cr
;
