\ ╔══════════════════════════════════════════════════════════════╗
\ ║ DRIVER EPONA — Epona OS 2.0                                ║
\ ╠══════════════════════════════════════════════════════════════╣
\ ║ Nom:        generic-xhci                                    ║
\ ║ Version:    0.1.0                                           ║
\ ║ Auteur:     Epona Team                                      ║
\ ║ License:    MIT                                             ║
\ ║ Description: Controleur hote USB xHCI generique             ║
\ ║                                                             ║
\ ║ Materiel supporte (PCI vendor:device) :                     ║
\ ║   tous les controleurs xHCI (AMD, Intel, ASMedia...)        ║
\ ║                                                             ║
\ ║ Classe PCI:  0C:03 (xHCI)                                   ║
\ ║ Requiert:    rien                                           ║
\ ║ Statut:      testing                                        ║
\ ╚══════════════════════════════════════════════════════════════╝
\
\ S'appuie sur l'init Rust crate::xhci (primitives xhci:*).
\ Primitives : xhci:init ( bar -- ok? ), xhci:port-count ( bar -- n ),
\              usb:init ( -- ok? ), usb:devices ( -- n slot1 ... ).

cr ." [DRV] chargement generic-xhci..." cr

s" generic-xhci" drv:name!
0 1 0 drv:version!
s" MIT" drv:license!
s" Controleur hote USB xHCI generique" drv:desc!

\ --- Type du driver : Usb ----------------------------------------------------
5 drv:type!

\ --- Classes xHCI / EHCI / UHCI ----------------------------------------------
pci:add-class 0x0C 0x03
pci:add-class 0x0C 0x02
pci:add-class 0x0C 0x00

\ --- drv:probe  ( bar bus dev func -- ok? ) ---------------------------------
\ Un hote USB est present si sa BAR0 est non nulle.
: drv:probe  ( bar bus dev func -- ok? ) { bar bus dev func }
    bar 0= if
        s" generic-xhci: BAR0 nulle" drv:warn
        0
    else
        -1
    then
;

\ --- drv:init  ( bar bus dev func -- ok? ) -----------------------------------
\ Initialise le controleur via crate::xhci et rapporte le nombre de
\ peripheriques connectes.
: drv:init  ( bar bus dev func -- ok? ) { bar bus dev func }
    bar xhci:init if
        bar xhci:port-count
        ." [xhci] ports/periphs USB : " u. cr
        s" xHCI initialise" drv:ok
        -1
    else
        s" generic-xhci: echec init xHCI" drv:err
        0
    then
;

\ --- drv:fini  ( -- ) ---------------------------------------------------------
\ Arret du controleur (primitif : pas de stop Rust complet dans cette branche).
: drv:fini  ( -- )
    s" xHCI arrete" drv:ok
;

\ --- Enregistrement -----------------------------------------------------------
drv:register
