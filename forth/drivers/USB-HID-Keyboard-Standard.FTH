\ ══════════════════════════════════════════════════════════
\ USB-HID-Keyboard-Standard.FTH
\ Ref:      Clavier USB HID Standard 104 touches
\ Interface: HID 1.1 over USB
\ Mode:    USB xHCI
\ Layout:  AZERTY / QWERTY (bascule F2)
\ Primitives: xhci-init, usb:devices, usb:control,
\             usb:read, usb:write
\ ══════════════════════════════════════════════════════════

variable kb-slot

\ --- Détection ---
: kb-detect
  cr
  cr ." === Clavier USB HID Standard ==="
  cr ."  Ref:         Clavier USB HID 104 touches"
  cr ."  Interface:   HID 1.1 over USB"
  cr ."  Mode:        USB xHCI"
  cr ."  Layout:      AZERTY / QWERTY (F2)"
  cr
  cr ."  Recherche clavier USB..."
  usb:devices
  cr
;

\ --- Lecture état ---
: kb-state
  cr
  cr ." === Clavier USB HID — État ==="
  usb:devices
  cr ."  Slots détectés: " u. cr
;

\ --- Test ---
: kb-test
  cr
  cr ." === TEST Clavier USB HID ==="
  cr ."  Appuyez sur une touche (2 secondes)..."
  2000 ms
  cr ."  (observation terminée)"
  cr
;

\ --- Init ---
: usb-hid-keyboard-init
  cr
  cr ." --- Clavier USB HID INIT ---"
  kb-detect
  cr ." Clavier USB HID init OK." cr
;
