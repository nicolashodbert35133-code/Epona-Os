\ ══════════════════════════════════════════════════════════
\ ELAN-Tactile-I2C.FTH
\ Marque:   ELAN Microelectronics
\ Ref:      Tactile Precision Touchpad (I2C HID)
\ Device:   04F3h:0510h ou 04F3h:3410h (selon modèle)
\ Bus:      I2C over AMD I2C Controller
\ AMD I2C:  1022h:15E4h
\ Primitives: dw-i2c-init, dw-i2c-probe, i2c-read,
\             i2c.probe, souris, souris?
\ ══════════════════════════════════════════════════════════

\ --- Variables ---
variable elan-i2c-base

\ --- Info ---
: elan-tactile-info
  cr
  cr ." === ELAN Tactile (Precision Touchpad) ==="
  cr ."  Marque:      ELAN Microelectronics"
  cr ."  Ref:         Precision Touchpad (I2C HID)"
  cr ."  Vendor ID:   04F3h"
  cr ."  Device ID:   0510h ou 3410h"
  cr ."  Bus:         I2C HID"
  cr ."  AMD I2C:     1022h:15E4h"
  cr
;

\ --- Scan ---
: elan-tactile-scan
  cr
  cr ." === ELAN Tactile SCAN ==="
  elan-tactile-info
  cr
  cr ."  Init I2C..."
  0xFED80000 dw-i2c-init if
    cr ."  I2C INIT:    OK"
  else
    cr ."  I2C INIT:    ÉCHEC"
  then
  cr
  cr ."  Scan bus I2C..."
  0xFED80000 i2c.probe
  cr
  cr ."  Statut souris:"
  souris? if
    cr ."    Souris DÉTECTÉE"
  else
    cr ."    Pas de souris"
  then
  cr
  cr ." ELAN tactile scan OK." cr
;

\ --- Test ---
: elan-tactile-test
  cr
  cr ." === TEST ELAN Tactile ==="
  cr ."  Lecture position souris..."
  souris
  cr ."    X: " u. cr ."    Y: " u. cr ."    Btn: " u. cr
  cr ."  Test ELAN tactile OK." cr
;

\ --- Init ---
: elan-tactile-init
  cr
  cr ." --- ELAN Tactile INIT ---"
  elan-tactile-scan
  cr ." ELAN tactile init OK." cr
;
