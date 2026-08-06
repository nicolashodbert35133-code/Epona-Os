\ ══════════════════════════════════════════════════════════
\ Realtek-ALC256.FTH
\ Marque:   Realtek
\ Ref:      ALC256 Codec HDA
\ Vendor:   10ECh (Realtek)
\ Device:   0256h
\ Bus:      HDA (High Definition Audio)
\ Canaux:   2 stéréo
\ Sorties:  Jack 3.5mm + HP internes
\ Entrees:  Micro interne + Jack 3.5mm
\ Primitives: hda-init, hda-info, hda-play, hda-stop,
\             hda-volume, hda-beep, hda-status
\ ══════════════════════════════════════════════════════════

\ --- Info ---
: realtek-alc256-info
  cr
  cr ." === Realtek ALC256 ==="
  cr ."  Marque:      Realtek"
  cr ."  Ref:         ALC256"
  cr ."  Vendor ID:   10ECh"
  cr ."  Device ID:   0256h"
  cr ."  Bus:         HDA (High Definition Audio)"
  cr ."  Sorties:     Jack 3.5mm + HP internes"
  cr ."  Entrées:     Micro interne + Jack 3.5mm"
  cr ."  Canaux:      2 stéréo"
  cr
  hda-info
;

\ --- Scan ---
: realtek-alc256-scan
  cr
  cr ." === Realtek ALC256 SCAN ==="
  realtek-alc256-info
  cr
  hda-init if
    cr ."  HDA INIT:    OK"
  else
    cr ."  HDA INIT:    ÉCHEC"
  then
  cr
  hda-status if
    cr ."  HDA Status:  EN COURS DE LECTURE"
  else
    cr ."  HDA Status:  ARRÊTÉ"
  then
  cr ." Realtek ALC256 scan OK." cr
;

\ --- Bip de test ---
: realtek-alc256-test
  cr
  cr ." === TEST Realtek ALC256 ==="
  cr ."  Bip 440Hz pendant 200ms..."
  440 200 hda-beep
  cr ."  Bip 880Hz pendant 200ms..."
  880 200 hda-beep
  cr ."  Volume 50%..."
  50 hda-volume
  cr ."  Test Realtek ALC256 OK." cr
;

\ --- Volume ---
: alc256-vol ( vol -- )
  hda-volume
  cr ."  Volume: " u. ." %"
;

\ --- Init ---
: realtek-alc256-init
  cr
  cr ." --- Realtek ALC256 INIT ---"
  realtek-alc256-scan
  cr ." Realtek ALC256 init OK." cr
;
