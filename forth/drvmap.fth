\ ============================================================================
\ drvmap.fth — Base de données PCI → driver (DEV_GUIDE_DRIVERS.md §5)
\ Format : pci:entry <vendor-hex> <device-hex> s" <chemin-du-driver>"
\          pci:entry 0000 0000 s" <générique-classe>"   (fallback)
\
\ NOTE : l'interpréteur Epona parse les nombres en base courante. Les
\ valeurs hexadécimales utilisent 0x... ou la base hex (cf. `hex`).
\
\ Mémoire : voir drvlib.fth — uniquement `create` (espace `here`), jamais
\ `variable`, pour éviter le chevauchement variables.len() / here.
\ ============================================================================

cr ." [DRVMAP] base de correspondance PCI->driver" cr

\ --- Helpers arithmétiques ----------------------------------------------------
: 4* 4 * ;

\ --- Table DRVMAP -----------------------------------------------------------
create DRVMAP-DB 128 allot   \ 32 entrées × 4 cellules (vid did addr len)
create DRVMAP-COUNT
0 DRVMAP-COUNT !
create FOUND-IDX
-1 FOUND-IDX !

\ pci:entry ( vid did addr len -- ) : ajoute une entrée à la table
: pci:entry ( vid did addr len -- ) { v d a l }
    DRVMAP-COUNT @ 32 >= if
        drop drop drop drop
    else
        l DRVMAP-COUNT @ 4* 3+ DRVMAP-DB + !
        a DRVMAP-COUNT @ 4* 2+ DRVMAP-DB + !
        d DRVMAP-COUNT @ 4* 1+ DRVMAP-DB + !
        v DRVMAP-COUNT @ 4* DRVMAP-DB + !
        1 DRVMAP-COUNT +!
    then
;

\ drvmap:find ( vid did -- addr len ) : cherche le driver pour un périphérique
\ 1) correspondance exacte vid:did, 2) fallback générique 0000:0000
\ Retourne ( 0 0 ) si rien ne correspond.
: drvmap:find ( vid did -- addr len ) { v d }
    -1 FOUND-IDX !
    DRVMAP-COUNT @ 0 ?do
        i 4* DRVMAP-DB + @ v = if
            i 4* 1+ DRVMAP-DB + @ d = if
                i FOUND-IDX !
            then
        then
    loop
    FOUND-IDX @ dup 0 >= if
        4* 2+ DRVMAP-DB + @
        FOUND-IDX @ 4* 3+ DRVMAP-DB + @
    else
        drop
        \ -- fallback générique --
        -1 FOUND-IDX !
        DRVMAP-COUNT @ 0 ?do
            i 4* DRVMAP-DB + @ 0 = if
                i 4* 1+ DRVMAP-DB + @ 0 = if
                    i FOUND-IDX !
                then
            then
        loop
        FOUND-IDX @ dup 0 >= if
            4* 2+ DRVMAP-DB + @
            FOUND-IDX @ 4* 3+ DRVMAP-DB + @
        else
            drop 0 0
        then
    then
;

\ ============================================================================
\ Entrées de la table. Ajouter ici : pci:entry 1022 15dd s" DRIVERS/...fth"
\ Les chemins sont relatifs à la racine de la clé USB (EPONA/).
\ ============================================================================

\ --- Entrées par défaut (matériel de la machine de dev) ---------------------
pci:entry 0x15b7 0x5017 s" forth/drivers/WD-SN770-NVMe.FTH"      \ WD Black SN770 NVMe
pci:entry 0x1022 0x1631 s" forth/drivers/AMD-Ryzen5-5500U.FTH"    \ AMD Cezanne host

\ --- Entrées exemples QEMU (guide §11 post-implémentation) -------------------
\ Chargées uniquement si le périphérique est présent (probe par vendor ID).
pci:entry 0x1234 0x1111 s" forth/drivers/bochs-vga.fth"          \ Bochs VGA (QEMU)
pci:entry 0x1af4 0x1000 s" forth/drivers/virtio-net.fth"         \ VirtIO net (QEMU)

\ --- Autres exemples commentés ----------------------------------------------
\ pci:entry 1022 15dd s" DRIVERS/30_gpu/1002_15dd.fth"    \ AMD Raven/Picasso APU
\ pci:entry 15b7 5006 s" DRIVERS/20_storage/generic_nvme.fth"  \ WD SN500

\ --- Fallback génériques ----------------------------------------------------
\ pci:entry 0000 0000 s" DRIVERS/20_storage/generic_nvme.fth"  \ stockage NVMe
