\ ============================================================================
\ drvlib.fth — Framework driver Epona OS (Phase 3)
\ Chargé par l'autoloader noyau (drv_ensure_stdlib) avant le scan PCI.
\ Fournit les mots de base utilisés par les drivers FTH du guide §7.
\
\ IMPORTANT : dans l'interpréteur Epona, `variable` alloue à variables.len()
\ alors que `create` alloue à `here` (les deux partent de 0). Mélanger les deux
\ fait se chevaucher les cellules. Ce fichier utilise donc UNIQUEMENT `create`
\ (espace `here`, monotone) pour toute sa mémoire persistante.
\ ============================================================================

cr ." [DRVLIBS] framework driver charge" cr

\ --- Types de drivers (guide §7.1) ------------------------------------------
0 constant Generic
1 constant Network
2 constant Audio
3 constant Storage
4 constant Input
5 constant Usb
6 constant Gpu

\ --- Compteurs / flags (1 cellule chacun) ------------------------------------
create DRV-NEXT-ID          \ prochain id d'enregistrement
0 DRV-NEXT-ID !
create DRV-TYPE             \ type du driver courant
0 DRV-TYPE !
create DRV-REGISTERED       \ flag : drv:register déjà appelé ?
0 DRV-REGISTERED !

\ --- Buffers métadonnées (un octet par cellule) ------------------------------
create DRV-NAME 128 allot     \ nom du driver
create DRV-NAME-LEN
0 DRV-NAME-LEN !
create DRV-DESC 256 allot     \ description
create DRV-DESC-LEN
0 DRV-DESC-LEN !
create DRV-LIC 64 allot       \ license
create DRV-LIC-LEN
0 DRV-LIC-LEN !
create DRV-VER-MAJ            \ version majeure
create DRV-VER-MIN
create DRV-VER-PAT

\ --- b-copy : copie n octets (un par cellule) de src vers dest --------------
: b-copy ( src dest n -- ) { s d n }
    n 0 do
        s i + @ d i + !
    loop
;

\ --- Métadonnées du driver ------------------------------------------------
: drv:name! ( addr len -- ) { a l }
    l 0< if
        \ ignore
    else
        l 127 min DRV-NAME-LEN !
        a DRV-NAME l 127 min b-copy
    then
;

: drv:version! ( maj min patch -- ) { ma mi pa }
    pa DRV-VER-PAT !
    mi DRV-VER-MIN !
    ma DRV-VER-MAJ !
;

: drv:license! ( addr len -- ) { a l }
    l 0< if
        \ ignore
    else
        l 63 min DRV-LIC-LEN !
        a DRV-LIC l 63 min b-copy
    then
;

: drv:desc! ( addr len -- ) { a l }
    l 0< if
        \ ignore
    else
        l 255 min DRV-DESC-LEN !
        a DRV-DESC l 255 min b-copy
    then
;

: drv:type! ( type -- ) DRV-TYPE ! ;

\ --- Accesseurs (utilisés par l'autoloader Rust) ----------------------------
: drv:name-string ( -- addr len ) DRV-NAME DRV-NAME-LEN @ ;
: drv:desc-string ( -- addr len ) DRV-DESC DRV-DESC-LEN @ ;
: drv:license-string ( -- addr len ) DRV-LIC DRV-LIC-LEN @ ;
: drv:version ( -- maj min patch ) DRV-VER-MAJ @ DRV-VER-MIN @ DRV-VER-PAT @ ;

\ --- Logging ---------------------------------------------------------------
: drv:log  ( addr len -- ) s" [DRV] " type type cr ;
: drv:warn ( addr len -- ) s" [DRV!WARN] " type type cr ;
: drv:err  ( addr len -- ) s" [DRV!ERR] " type type cr ;
: drv:ok   ( addr len -- ) s" [DRV+OK] " type type cr ;

\ --- Table des IDs PCI du driver courant (pour auto-probe) ------------------
create PCI-DEVICES 64 allot   \ 32 entrées × 2 cellules (vid did)
create PCI-COUNT
0 PCI-COUNT !

: pci:add-id ( vid did -- ) { v d }
    PCI-COUNT @ 32 >= if
        drop drop
    else
        v PCI-COUNT @ 2* PCI-DEVICES + !
        d PCI-COUNT @ 2* 1+ PCI-DEVICES + !
        1 PCI-COUNT +!
    then
;

: pci:add-class ( class sub -- ) { c s }
    \ Les entrées génériques (0000:0000) sont réservées au fallback classe.
    c 0= if
        drop drop
    else
        c PCI-COUNT @ 2* PCI-DEVICES + !
        s PCI-COUNT @ 2* 1+ PCI-DEVICES + !
        1 PCI-COUNT +!
    then
;

\ --- Registre interne DRV-DB (rapport final) -------------------------------
create DRV-DB 128 allot   \ 32 entrées × 4 cellules (id nom-len etat version)
create DRV-DB-COUNT
0 DRV-DB-COUNT !

\ --- Déclare une entrée DRV-DB au moment de drv:register --------------------
: drv-db-add ( -- )
    DRV-DB-COUNT @ 32 >= if
        \ table pleine
    else
        DRV-NEXT-ID @ DRV-DB-COUNT @ 4* DRV-DB + !
        DRV-NAME-LEN @ DRV-DB-COUNT @ 4* 1+ DRV-DB + !
        DRV-TYPE @ DRV-DB-COUNT @ 4* 2+ DRV-DB + !
        DRV-REGISTERED @ DRV-DB-COUNT @ 4* 3+ DRV-DB + !
        1 DRV-DB-COUNT +!
        1 DRV-NEXT-ID +!
    then
;

\ --- Enregistrement du driver ----------------------------------------------
: drv:register ( -- )
    drv:name-string DRV-TYPE @ 0 dev:register drop
    1 DRV-REGISTERED !
    drv-db-add
;

\ --- Probe / Init par défaut (un driver peut les redéfinir) ----------------
: drv:probe ( bar bus dev func -- ok? ) drop drop drop drop -1 ;
: drv:init  ( bar bus dev func -- ok? ) drop drop drop drop -1 ;
: drv:fini  ( -- ) ;

\ --- Affichage hexadécimal sur largeur fixe (guide §6.1) --------------------
: h.2 ( n -- )
    0xff and
    dup 0x10 < if s" 0" type then
    hex u. decimal
;
: h.4 ( n -- )
    0xffff and
    dup 0x1000 < if s" 0" type then
    dup 0x100 < if s" 0" type then
    dup 0x10 < if s" 0" type then
    hex u. decimal
;
: h.8 ( n -- ) hex u. decimal ;

\ --- mmio-dump ( addr n -- ) : dump n octets MMIO en hexadécimal -----------
: mmio-dump ( addr n -- ) { a n }
    n 0 ?do
        a i + mmio-b@ h.2
        i 1+ 16 mod 0= if
            cr
        else
            space
        then
    loop
    cr
;
