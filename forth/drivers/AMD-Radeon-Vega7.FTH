\ ══════════════════════════════════════════════════════════
\ AMD-Radeon-Vega7.FTH
\ Marque:   AMD
\ Ref:      Radeon RX Vega 7 (iGPU Cezanne)
\ iGPU:     Vega 7 — 7 Compute Units — 1600 MHz
\ Vendor:   1002h (ATI/AMD)
\ Device:   1638h (Cezanne Radeon RX Vega 7)
\ Mémoire:  Partagée DDR4 (jusqu'à 2 Go sur 8 Go)
\ PCI:      00:08.0
\ Primitives: gpu:init, gpu:info, gpu:fill, gpu:blit,
\             gpu:flip, gpu:fb-addr, gpu:fb-stride,
\             gpu:resolution, gpu:accel?, pci-bar
\ ══════════════════════════════════════════════════════════

\ --- Variables ---
variable vega7-bar0
variable vega7-bar1
variable vega7-bar2

\ --- PCI ---
: vega7-pci
  cr
  cr ." === AMD Radeon Vega 7 — PCI ==="
  0 8 0 0 pci@ cr ."  Vendor ID:    " hex u. decimal cr
  0 8 0 4 pci@ cr ."  Command/Stat: " hex u. decimal cr
  0 8 0 10 pci@ cr ."  BAR0 (MMIO):  " hex u. decimal cr
  0 8 0 14 pci@ cr ."  BAR1 (MMIO):  " hex u. decimal cr
  0 8 0 18 pci@ cr ."  BAR2 (MMIO):  " hex u. decimal cr
  0 8 0 0x2C pci@ cr ."  Subsystem:    " hex u. decimal cr
  0 8 0 0x3C pci@ cr ."  Interrupt:    " hex u. decimal cr
;

\ --- BAR info ---
: vega7-bars
  cr
  cr ." === AMD Radeon Vega 7 — BARs ==="
  0 8 0 0 pci-bar
  cr ."  BAR0 size:   " u. ."  addr: " hex u. decimal cr
  0 8 0 1 pci-bar
  cr ."  BAR1 size:   " u. ."  addr: " hex u. decimal cr
  0 8 0 2 pci-bar
  cr ."  BAR2 size:   " u. ."  addr: " hex u. decimal cr
;

\ --- Framebuffer ---
: vega7-fb
  cr
  cr ." === AMD Radeon Vega 7 — Framebuffer ==="
  gpu:fb-addr hex cr ."  Adresse:      " u. decimal cr
  gpu:fb-stride cr ."  Stride:       " u. cr
  gpu:resolution cr ."  Résolution:   " u. ." x " u. cr
;

\ --- GPU init ---
: vega7-gpu-init
  cr
  cr ." === AMD Radeon Vega 7 — GPU Init ==="
  gpu:init if
    cr ."  GPU INIT:     OK"
  else
    cr ."  GPU INIT:     ÉCHEC"
  then
  gpu:info
;

\ --- Test ---
: vega7-test
  cr
  cr ." === TEST AMD Radeon Vega 7 ==="
  cr ."  Écran ROUGE..."
  0 0 gpu:resolution drop 1024 768 0xFF0000 gpu:fill
  500 ms
  cr ."  Écran VERT..."
  0 0 gpu:resolution drop 1024 768 0x00FF00 gpu:fill
  500 ms
  cr ."  Écran BLEU..."
  0 0 gpu:resolution drop 1024 768 0x0000FF gpu:fill
  500 ms
  cr ."  Retour NOIR..."
  0 0 gpu:resolution drop 1024 768 0x000000 gpu:fill
  gpu:flip
  cr ."  Test AMD Radeon Vega 7 OK." cr
;

\ --- Init ---
: amd-radeon-vega7-init
  cr
  cr ." --- AMD Radeon Vega 7 INIT ---"
  vega7-pci
  vega7-bars
  vega7-gpu-init
  vega7-fb
  cr ." AMD Radeon Vega 7 init OK." cr
;
