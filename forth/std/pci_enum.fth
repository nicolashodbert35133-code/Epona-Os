\ ============================================================================
\ pci_enum.fth — Énumération PCI (guide §6.2)
\ Utilise pci:list / pci:dev / pci:bar (primitives Rust 757/758/756).
\
\ Mémoire : voir drvlib.fth — uniquement `create` (espace `here`), jamais
\ `variable`, pour éviter le chevauchement variables.len() / here.
\ ============================================================================

cr ." [PCI-ENUM] enumeration PCI pret" cr

create PCI:COUNT
0 PCI:COUNT !
create PCI:FOUND
-1 PCI:FOUND !

\ pci:enum ( -- n ) : scanne le bus PCI, peuple le cache noyau
: pci:enum ( -- n )
    pci:list
    dup PCI:COUNT !
;

\ pci:count ( -- n ) : nombre de périphériques du dernier scan
: pci:count ( -- n ) PCI:COUNT @ ;

\ pci:info ( idx -- bus dev func vid did class sub )
: pci:info ( idx -- bus dev func vid did class sub )
    pci:dev
;

\ pci:find-vendor ( vid did -- idx|-1 ) : cherche une correspondance exacte
: pci:find-vendor ( vid did -- idx|-1 ) { v d }
    -1 PCI:FOUND !
    PCI:COUNT @ 0 ?do
        i pci:dev             \ ( bus dev func vid did class sub )
        2drop                 \ ( bus dev func vid did )
        drop drop drop        \ ( vid did )
        dup d = if            \ ( vid did ) — device match ?
            over v = if       \ ( vid did ) — vendor match ?
                2drop i PCI:FOUND !
            else
                2drop
            then
        else
            2drop
        then
    loop
    PCI:FOUND @
;

\ pci:bar@ ( idx n -- addr size ) : wrapper sur la primitive pci:bar
\ (la primitive pci:bar prend ( bus dev fn n -- addr size ) ; ce mot
\ extrait bus/dev/fn depuis l'index du scan — on ne redéfinit PAS pci:bar).
: pci:bar@ ( idx n -- addr size )
    >r
    dup pci:dev               \ ( idx bus dev fn vid did cls sub )
    drop drop drop drop       \ ( idx bus dev fn )
    drop                      \ ( bus dev fn )
    r>                        \ ( bus dev fn n )
    pci:bar
;

\ pci:find-class ( class sub -- idx|-1 ) : cherche une correspondance de classe
: pci:find-class ( class sub -- idx|-1 ) { c s }
    -1 PCI:FOUND !
    PCI:COUNT @ 0 ?do
        i pci:dev             \ ( bus dev fn vid did class sub )
        drop drop drop drop drop  \ ( class sub )
        dup s = if            \ ( class sub ) — subclass match ?
            over c = if       \ ( class sub ) — class match ?
                2drop i PCI:FOUND !
            else
                2drop
            then
        else
            2drop
        then
    loop
    PCI:FOUND @
;

\ pci:info+bar ( idx -- bus dev func vid did class sub bar0 )
: pci:info+bar ( idx -- bus dev func vid did class sub bar0 ) { i -- b0 b d f v dv c s }
    i 0 pci:bar@ drop to b0
    i pci:dev to s to c to dv to v to f to d to b
    b d f v dv c s b0
;

\ .pci ( idx -- ) : affiche une ligne de résumé du périphérique (avec BAR0)
: .pci ( idx -- ) { i -- b0 }
    i 0 pci:bar@ drop to b0
    i pci:dev                   \ ( bus dev func vid did class sub )
    >r >r >r >r >r >r >r        \ R: [bus dev func vid did class sub]
    hex
    ."  BDF " r> h.2 ." :" r> h.2 ." ." r> h.2
    ."  VID=" r> h.4 ."  DID=" r> h.4
    ."  CLS=" r> h.2 ." :" r> h.2
    ."  BAR0=" b0 h.8
    decimal cr
;

\ ── Affichage détaillé (guide §6.2) ────────────────────────────────────────

\ .bdf ( bus dev func -- ) : affiche bus:dev.func en hexa sur 2 chiffres
: .bdf ( bus dev func -- )
    hex
    h.2 ." :" h.2 ." ." h.2
    decimal
;

\ .vendor-name ( vid -- ) : nom approximatif du constructeur
\ PAS de `{ locals }` ici : Op::Exit ne les nettoie pas (cf. TEMPLATE.fth).
: .vendor-name ( vid -- )
    dup 0x1234 = if ." QEMU" exit then
    dup 0x1af4 = if ." VirtIO" exit then
    dup 0x1022 = if ." AMD" exit then
    dup 0x8086 = if ." Intel" exit then
    dup 0x8087 = if ." Intel" exit then
    dup 0x10de = if ." NVIDIA" exit then
    dup 0x15b7 = if ." WD" exit then
    dup 0x10ec = if ." Realtek" exit then
    dup 0x14e4 = if ." Broadcom" exit then
    dup 0x1969 = if ." Qualcomm" exit then
    dup 0x1002 = if ." AMD" exit then
    dup 0x1106 = if ." VIA" exit then
    dup 0x10ee = if ." Xilinx" exit then
    drop ." ?" ;

\ .class-name ( class -- ) : nom approximatif de la classe
: .class-name ( class -- )
    dup 0x01 = if ." Storage" exit then
    dup 0x02 = if ." Network" exit then
    dup 0x03 = if ." Display" exit then
    dup 0x04 = if ." Multimedia" exit then
    dup 0x05 = if ." Memory" exit then
    dup 0x06 = if ." Bridge" exit then
    dup 0x07 = if ." Communication" exit then
    dup 0x08 = if ." System" exit then
    dup 0x09 = if ." Input" exit then
    dup 0x0B = if ." Processor" exit then
    dup 0x0C = if ." Serial" exit then
    dup 0x0D = if ." Wireless" exit then
    drop ." ?" ;

