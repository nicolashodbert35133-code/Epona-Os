\ ============================================================================
\ ps2-keyboard.fth - Driver clavier PS/2 8042
\ ============================================================================
\ @DRIVER ps2-keyboard
\ @DESCRIPTION Controleur clavier PS/2 (i8042)
\ @VENDOR 0000
\ @DEVICE 0000
\ @CLASS 00:00
\ @TYPE Input
\ @AUTHOR Epona Team
\ @VERSION 1.0
\ @LICENSE MIT
\ ============================================================================

\ --- Types de drivers --------------------------------------------------------
0 constant Generic
1 constant Network
2 constant Audio
3 constant Storage
4 constant Input
5 constant Usb
6 constant Gpu

cr ." [PS2] Chargement driver clavier PS/2..." cr

\ --- Ports I/O du controleur 8042 -------------------------------------------
hex
0x60 constant PS2-DATA
0x64 constant PS2-CMD
decimal

\ --- Variables ---------------------------------------------------------------
variable ps2-kb-ok          \ flag: clavier detecte?
variable ps2-last-scancode  \ dernier scancode recu

\ --- Commandes PS/2 ----------------------------------------------------------
: ps2-wait-write ( -- )
    begin
        PS2-CMD inb
        0x02 and
    0= until
;

: ps2-wait-read ( -- )
    begin
        PS2-CMD inb
        0x01 and
    0= until
;

: ps2-write-cmd ( cmd -- )
    ps2-wait-write
    PS2-CMD outb
;

: ps2-write-data ( data -- )
    ps2-wait-write
    PS2-DATA outb
;

: ps2-read-data ( -- byte )
    ps2-wait-read
    PS2-DATA inb
;

\ --- Configuration du clavier -----------------------------------------------
: ps2-kb-reset ( -- flag )
    \ Envoyer commande reset
    0xFF ps2-write-data
    100 ms
    \ Lire ACK (0xFA)
    ps2-read-data 0xFA =
;

: ps2-kb-enable ( -- )
    \ Activer le clavier
    0xAE ps2-write-cmd
;

: ps2-kb-disable ( -- )
    \ Desactiver le clavier
    0xAD ps2-write-cmd
;

\ --- Initialisation controleur 8042 -----------------------------------------
: ps2-controller-init ( -- flag )
    \ Tester le controleur 8042
    \ Desactiver les peripheriques
    ps2-kb-disable

    \ Vider le buffer de sortie
    begin
        PS2-CMD inb
        0x01 and
    while
        PS2-DATA inb drop
    repeat

    \ Activer le clavier
    ps2-kb-enable

    \ Tester le clavier
    ps2-kb-reset if
        ." [PS2] Clavier detecte" cr
        -1
    else
        ." [PS2] Clavier non detecte" cr
        0
    then
;

\ --- Lecture scancode --------------------------------------------------------
: ps2-read-scancode ( -- scancode | -1 )
    PS2-CMD inb
    0x01 and if
        PS2-DATA inb
    else
        -1
    then
;

\ --- Traduction AZERTY simplifiee -------------------------------------------
: scancode>ascii ( scancode -- char | 0 )
    dup 0x10 = if drop 'a' exit then
    dup 0x11 = if drop 'z' exit then
    dup 0x12 = if drop 'e' exit then
    dup 0x13 = if drop 'r' exit then
    dup 0x14 = if drop 't' exit then
    dup 0x15 = if drop 'y' exit then
    dup 0x16 = if drop 'u' exit then
    dup 0x17 = if drop 'i' exit then
    dup 0x18 = if drop 'o' exit then
    dup 0x19 = if drop 'p' exit then
    dup 0x1E = if drop 'q' exit then
    dup 0x1F = if drop 's' exit then
    dup 0x20 = if drop 'd' exit then
    dup 0x21 = if drop 'f' exit then
    dup 0x22 = if drop 'g' exit then
    dup 0x23 = if drop 'h' exit then
    dup 0x24 = if drop 'j' exit then
    dup 0x25 = if drop 'k' exit then
    dup 0x26 = if drop 'l' exit then
    dup 0x2C = if drop 'm' exit then
    \ Chiffres
    dup 0x02 = if drop '&' exit then
    dup 0x03 = if drop 'e' exit then  \ accent aigu
    dup 0x04 = if drop '"' exit then
    dup 0x05 = if drop '\'' exit then
    dup 0x06 = if drop '(' exit then
    dup 0x07 = if drop '-' exit then
    dup 0x08 = if drop 'e' exit then  \ grave
    dup 0x09 = if drop '_' exit then
    dup 0x0A = if drop 'c' exit then  \ c cedille
    dup 0x0B = if drop 'a' exit then  \ a grave
    \ Entree / Espace
    dup 0x1C = if drop 13 exit then   \ Enter
    dup 0x39 = if drop 32 exit then   \ Space
    \ Backspace / Tab / Echap
    dup 0x0E = if drop 8  exit then   \ Backspace
    dup 0x0F = if drop 9  exit then   \ Tab
    dup 0x01 = if drop 27 exit then   \ Escape
    drop 0
;

\ --- Handler IRQ du clavier (si utilise en mode IRQ) -------------------------
: ps2-irq-handler ( vector -- )
    \ Vector = IRQ number
    ps2-read-scancode
    dup -1 = if drop exit then
    ps2-last-scancode !
;

\ --- Boucle de polling -------------------------------------------------------
: ps2-kb-poll ( -- char | 0 )
    ps2-read-scancode
    dup -1 = if drop 0 exit then
    dup ps2-last-scancode !
    \ Option: traduire en ASCII
;

\ --- find-device -------------------------------------------------------------
: find-device ( -- flag )
    \ Le controleur 8042 est fixe (legacy), pas de scan PCI
    \ On teste directement le port 0x64
    PS2-CMD inb
    \ Si le port repond, on considere le controleur present
    \ Ecrire une commande test (0xAA = test controller)
    0xAA ps2-write-cmd
    100 ms
    ps2-read-data 0x55 =  \ 0x55 = test OK
    if
        ." [PS2] Controleur 8042 detecte" cr
        ps2-kb-ok on
        -1
    else
        ." [PS2] Controleur 8042 absent" cr
        0
    then
;

\ --- hw-init ----------------------------------------------------------------
: hw-init ( -- flag )
    find-device 0= if 0 exit then
    ps2-controller-init
    dup ps2-kb-ok !
;

\ --- hw-reset ---------------------------------------------------------------
: hw-reset ( -- )
    ps2-kb-disable
    ps2-kb-ok off
;

\ --- hw-info ----------------------------------------------------------------
: hw-info ( -- )
    cr
    ." === Clavier PS/2 ===" cr
    ." Ports: 0x60/0x64" cr
    ." Etat: " ps2-kb-ok @ if ." OK" else ." Absent" then cr
;

\ --- Auto-enregistrement ----------------------------------------------------
: register-driver ( -- )
    hw-init if
        s" ps2-keyboard" Input driver-register if
            ." [PS2] Driver clavier enregistre" cr
        else
            ." [PS2] Echec enregistrement" cr
        then
    then
;

register-driver
