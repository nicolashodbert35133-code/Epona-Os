\ ╔══════════════════════════════════════════════════════════════╗
\ ║ DRIVER EPONA — Epona OS 2.0                                ║
\ ╠══════════════════════════════════════════════════════════════╣
\ ║ Nom:        generic-nvme                                    ║
\ ║ Version:    0.1.0                                           ║
\ ║ Auteur:     Epona Team                                      ║
\ ║ License:    MIT                                             ║
\ ║ Description: Controleur NVMe generique                      ║
\ ║                                                             ║
\ ║ Materiel supporte (PCI vendor:device) :                     ║
\ ║   tous les SSD NVMe (Samsung, WD/SanDisk, Intel, Micron...) ║
\ ║                                                             ║
\ ║ Classe PCI:  01:08 (NVMe)                                   ║
\ ║ Requiert:    rien                                           ║
\ ║ Statut:      testing                                        ║
\ ╚══════════════════════════════════════════════════════════════╝
\
\ S'appuie sur l'init Rust crate::nvme (primitives nvme:*).
\ Primitives : nvme:init ( -- ok? ), nvme:ns-count ( bar -- n ),
\              nvme:read/write ( lba count buf -- ok ).

cr ." [DRV] chargement generic-nvme..." cr

s" generic-nvme" drv:name!
0 1 0 drv:version!
s" MIT" drv:license!
s" Controleur NVMe generique" drv:desc!

\ --- Type du driver : Storage ------------------------------------------------
3 drv:type!

\ --- Classe NVMe --------------------------------------------------------------
pci:add-class 0x01 0x08

\ --- drv:probe  ( bar bus dev func -- ok? ) ---------------------------------
: drv:probe  ( bar bus dev func -- ok? ) { bar bus dev func }
    bar 0= if
        s" generic-nvme: BAR0 nulle" drv:warn
        0
    else
        -1
    then
;

\ --- drv:init  ( bar bus dev func -- ok? ) -----------------------------------
\ Initialise le controleur via crate::nvme puis rapporte les namespaces.
: drv:init  ( bar bus dev func -- ok? ) { bar bus dev func }
    nvme:init if
        bar nvme:ns-count
        ." [nvme] namespaces : " u. cr
        s" NVMe initialise" drv:ok
        -1
    else
        s" generic-nvme: echec init NVMe" drv:err
        0
    then
;

\ --- drv:fini  ( -- ) ---------------------------------------------------------
\ Arret du controleur (primitif : pas de stop Rust complet dans cette branche).
: drv:fini  ( -- )
    s" NVMe arrete" drv:ok
;

\ --- Enregistrement -----------------------------------------------------------
drv:register
