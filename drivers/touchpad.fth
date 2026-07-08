\ Pilote ELAN071A Touchpad pour AetherOS
\ A charger avec: sys:load touchpad.fth
\ Puis: sys:probe
\ 
\ Ce pilote cherche le touchpad ELAN071A sur les
\ 6 controleurs I2C AMDI0010 (0xFEDC2000..0xFEDCB000)

\ Verifier COMP_TYPE d'un controleur
: comp? ( base -- base 0 | 0 ) 
    dup mmio@        \ lire COMP_TYPE
    0x44570140 =     \ DesignWare ?
    if
    else
        drop 0       \ echec
    then
;

\ Initialiser un controleur DesignWare
: init-ctrl ( base -- ok? )
    dw-i2c-init
;

\ Tester si un peripherique I2C repond
: test-addr ( base addr -- ok? )
    dw-i2c-probe
;

\ Initialisation du touchpad
: touchpad-init ( -- ok? )
    ." Touchpad ELAN071A init..." cr
    
    \ Essayer chaque base I2C connue
    0xFEDC2000 comp? dup if
        init-ctrl if
            ."  I2CA@" cr
            drop 1 exit
        then
    then drop
    
    0xFEDC3000 comp? dup if
        init-ctrl if
            ."  I2CB@" cr
            drop 1 exit
        then
    then drop
    
    0xFEDC4000 comp? dup if
        init-ctrl if
            ."  I2CC@" cr
            drop 1 exit
        then
    then drop
    
    0xFEDC5000 comp? dup if
        init-ctrl if
            ."  I2CD@" cr
            drop 1 exit
        then
    then drop
    
    0xFEDC6000 comp? dup if
        init-ctrl if
            ."  I2CE@" cr
            drop 1 exit
        then
    then drop
    
    0xFEDCB000 comp? dup if
        init-ctrl if
            ."  I2CF@" cr
            drop 1 exit
        then
    then drop
    
    ."  AUCUN" cr
    0
;

\ Lecture touchpad
: touchpad-read ( -- x y btn )
    0 0 0
;

\ Enregistrer ce pilote dans le noyau
"touchpad" sys:register
