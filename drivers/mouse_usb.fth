\ Pilote souris USB/PS2/I2C
\ Detecte automatiquement le materiel disponible via le firmware UEFI
\ + les pilotes PS/2 et I2C integres

: usb-mouse-init ( -- ok? )
    ." Souris..." cr
    souris?                              \ Verifie si materiel detecte
    dup if ."  Detectee" cr then
;

: usb-mouse-read ( -- x y btn )
    souris
;

\ Enregistrer le pilote
sys:register usb-mouse