\ ============================================================
\ DRIVER_SMBUS.FTH — Pilote SMBus (AMD)
\ PCI: 00:14.0  V1022 D790b  class 0C subclass 05
\ ============================================================
\ Pilote bas-niveau SMBus via I/O ports (0x20-0x27).
\ Permet de communiquer avec les peripheriques SMBus :
\ - EEPROM ( SPD RAM, capteurs de temperature )
\ - PMU / chargeur batterie
\ - Capteurs I2C/SMBus du chipset
\
\ ATTENTION : SMBus est partage avec le firmware UEFI.
\ Ne pas abuser des acces SMBus pendant le boot.
\
\ Charger : require DRIVER_SMBUS.FTH
\ Ou :     sys:load DRIVER_SMBUS.FTH
\ ============================================================

cr ." [SMBUS] Chargement pilote SMBus AMD..." cr

\ ── Constantes AMD SMBus (FCH) ───────────────────────────────
hex
0x20 constant SMBUS-HOST-STD    \ Host Status Register (IO base)
decimal
5 constant SMBUS-TIMEOUT         \ timeout en ms

\ ── Variables ────────────────────────────────────────────────
variable smbus-ok   0 smbus-ok !

\ ── Primitives bas niveau ────────────────────────────────────
: smbus-inb ( port -- val )
    inb
;

: smbus-outb ( val port -- )
    outb
;

\ ── Attendre que SMBus soit pret ─────────────────────────────
: smbus-wait-ready ( -- ok? )
    SMBUS-TIMEOUT 0 do
        SMBUS-HOST-STD smbus-inb
        0x01 and 0= if          \ bit 0 (HOST_BUSY) clear?
            1 exit
        then
        1 stall-us
    loop
    0
;

\ ── Lire le registre de statut ──────────────────────────────
: smbus-status ( -- status )
    SMBUS-HOST-STD smbus-inb
;

\ ── Vider le status ─────────────────────────────────────────
: smbus-clear ( -- )
    0xFF SMBUS-HOST-STD SMBUS-HOST-STD + 4 + smbus-outb
;

\ ── SMBus Read Byte ──────────────────────────────────────────
\ Lit 1 octet depuis l'adresse SMBus slave au registre reg
\ Retourne la valeur ou -1 si erreur
: smbus-read-byte ( slave reg -- val | -1 )
    smbus-wait-ready 0= if -1 exit then

    \ Ecrire l'adresse du peripherique (slave << 1 | 1 = read)
    slave 1 lshift 1 or
    SMBUS-HOST-STD 4 + smbus-outb

    \ Ecrire le registre cible
    reg SMBUS-HOST-STD 3 + smbus-outb

    \ Demarrer la transaction (command 0x48 = quick read / byte read)
    0x48 SMBUS-HOST-STD 2 + smbus-outb

    \ Attendre fin de transaction
    smbus-wait-ready 0= if -1 exit then

    \ Verifier les erreurs
    SMBUS-HOST-STD smbus-inb
    dup 0x10 and if             \ SMBus_alert?
        drop -1 exit
    then
    dup 0x20 and if             \ failed?
        drop -1 exit
    then
    drop

    \ Lire le resultat
    SMBUS-HOST-STD 5 + smbus-inb
;

\ ── SMBus Write Byte ─────────────────────────────────────────
\ Ecrit 1 octet a l'adresse SMBus slave, registre reg, valeur val
\ Retourne 1 si ok, 0 si erreur
: smbus-write-byte ( slave reg val -- ok? )
    smbus-wait-ready 0= if 0 exit then

    \ Adresse du peripherique (slave << 1 | 0 = write)
    slave 1 lshift
    SMBUS-HOST-STD 4 + smbus-outb

    \ Registre cible
    reg SMBUS-HOST-STD 3 + smbus-outb

    \ Donnee a ecrire
    val SMBUS-HOST-STD 5 + smbus-outb

    \ Commande : byte write (0x48)
    0x48 SMBUS-HOST-STD 2 + smbus-outb

    \ Attendre fin
    smbus-wait-ready 0= if 0 exit then

    \ Verifier erreurs
    SMBUS-HOST-STD smbus-inb
    0x30 and 0=                \ ni alert ni failed
;

\ ── SMBus Quick Command ──────────────────────────────────────
: smbus-quick ( slave read? -- ok? )
    smbus-wait-ready 0= if 0 exit then
    slave 1 lshift or
    SMBUS-HOST-STD 4 + smbus-outb
    0x40 SMBUS-HOST-STD 2 + smbus-outb
    smbus-wait-ready 0= if 0 exit then
    SMBUS-HOST-STD smbus-inb
    0x30 and 0=
;

\ ── Detecter si SMBus est present ────────────────────────────
: smbus-detect ( -- ok? )
    SMBUS-HOST-STD smbus-inb
    0xFF <>                     \ Si tous les bits a 1, pas de HW
;

\ ── Scanner les adresses SMBus courantes ─────────────────────
: smbus-scan ( -- )
    cr ." [SMBUS] Scan 0x08..0x77 :" cr
    0x08 0x78 do
        i 1 smbus-quick if
            ."  Adresse 0x" hex i . decimal ." detectee" cr
        then
    loop
    cr
;

\ ── Init ─────────────────────────────────────────────────────
: smbus-init ( -- ok? )
    cr ." [SMBUS] Detection AMD SMBus (PCI 00:14.0)..." cr
    smbus-detect
    dup if
        1 smbus-ok !
        smbus-clear
        ." [SMBUS] SMBus AMD detecte" cr
    else
        0 smbus-ok !
        ." [SMBUS] SMBus non detecte" cr
    then
;

\ ── Enregistrement ───────────────────────────────────────────
sys:register smbus

\ ── Init auto ────────────────────────────────────────────────
smbus-init drop

cr ." [SMBUS] Pilote charge. Mots :" cr
."   smbus-init       ( -- ok? )     initialiser" cr
."   smbus-detect     ( -- ok? )     detecter SMBus" cr
."   smbus-scan       ( -- )         scanner adresses" cr
."   smbus-read-byte  ( s r -- v )   lire 1 octet" cr
."   smbus-write-byte ( s r v -- ok? ) ecrire 1 octet" cr
."   smbus-status     ( -- st )      registre status" cr
."   smbus-clear      ( -- )         vider status" cr
cr
