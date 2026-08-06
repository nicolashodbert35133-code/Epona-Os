\ ╔══════════════════════════════════════════════════════════════╗
\ ║ DRIVER EPONA — Epona OS 2.0                                ║
\ ╠══════════════════════════════════════════════════════════════╣
\ ║ Nom:        generic-ahci                                    ║
\ ║ Version:    0.1.0                                           ║
\ ║ Auteur:     Epona Team                                      ║
\ ║ License:    MIT                                             ║
\ ║ Description: Controleur SATA AHCI generique                 ║
\ ║                                                             ║
\ ║ Materiel supporte (PCI vendor:device) :                     ║
\ ║   tous les controleurs AHCI (AMD FCH, Intel PCH, ASMedia)   ║
\ ║                                                             ║
\ ║ Classe PCI:  01:06 (SATA AHCI)                              ║
\ ║ Requiert:    rien                                           ║
\ ║ Statut:      testing                                        ║
\ ╚══════════════════════════════════════════════════════════════╝
\
\ S'appuie sur l'init Rust crate::ahci (primitives ahci:*).
\ Primitives : ahci:init ( -- ok? ), ahci:disk-count ( bar -- n ),
\              ahci:port-count ( bar -- n ), ahci:read/write.

cr ." [DRV] chargement generic-ahci..." cr

s" generic-ahci" drv:name!
0 1 0 drv:version!
s" MIT" drv:license!
s" Controleur SATA AHCI generique" drv:desc!

\ --- Type du driver : Storage ------------------------------------------------
3 drv:type!

\ --- Classe AHCI --------------------------------------------------------------
pci:add-class 0x01 0x06

\ --- drv:probe  ( bar bus dev func -- ok? ) ---------------------------------
: drv:probe  ( bar bus dev func -- ok? ) { bar bus dev func }
    bar 0= if
        s" generic-ahci: BAR0 nulle" drv:warn
        0
    else
        -1
    then
;

\ --- drv:init  ( bar bus dev func -- ok? ) -----------------------------------
\ Initialise le controleur via crate::ahci puis rapporte les disques.
: drv:init  ( bar bus dev func -- ok? ) { bar bus dev func }
    ahci:init if
        bar ahci:disk-count
        ." [ahci] disques SATA : " u. cr
        s" AHCI initialise" drv:ok
        -1
    else
        s" generic-ahci: echec init AHCI" drv:err
        0
    then
;

\ --- drv:fini  ( -- ) ---------------------------------------------------------
\ Arret du controleur (primitif : pas de stop Rust complet dans cette branche).
: drv:fini  ( -- )
    s" AHCI arrete" drv:ok
;

\ --- Enregistrement -----------------------------------------------------------
drv:register
