\ ╔══════════════════════════════════════════════════════════════╗
\ ║ DRIVER EPONA — Epona OS 2.0                                ║
\ ╠══════════════════════════════════════════════════════════════╣
\ ║ Nom:        usb-hid                                         ║
\ ║ Version:    0.1.0                                           ║
\ ║ Auteur:     Epona Team                                      ║
\ ║ License:    MIT                                             ║
\ ║ Description: Clavier / souris USB (HID)                     ║
\ ║             Depend du controleur xHCI (generic-xhci).       ║
\ ║                                                             ║
\ ║ Materiel supporte (PCI vendor:device) :                     ║
\ ║   aucun en PCI — peripheriques USB derriere le xHCI         ║
\ ║                                                             ║
\ ║ Classe PCI:  —                                               ║
\ ║ Requiert:    generic-xhci (controleur USB)                  ║
\ ║ Statut:      testing                                        ║
\ ╚══════════════════════════════════════════════════════════════╝
\
\ Primitives : usb:devices ( -- n slot1 port1 speed1 vid1 pid1 conf1 ... ),
\              xhci-souris? ( -- flag ), xhci-souris ( -- dx dy btn ).

cr ." [DRV] chargement usb-hid..." cr

s" usb-hid" drv:name!
0 1 0 drv:version!
s" MIT" drv:license!
s" Clavier / souris USB (HID)" drv:desc!

\ --- Type du driver : Input ---------------------------------------------------
4 drv:type!

\ --- drv:probe  ( bar bus dev func -- ok? ) ---------------------------------
\ Ne depend pas d'un BDF PCI precis : toujours present si le systeme a
\ demarre (les peripheriques sont vus a travers le xHCI).
: drv:probe  ( bar bus dev func -- ok? ) { bar bus dev func }
    -1
;

\ --- drv:init  ( bar bus dev func -- ok? ) -----------------------------------
\ Verifie la presence d'une souris HID et compte les peripheriques USB.
: drv:init  ( bar bus dev func -- ok? ) { bar bus dev func }
    usb-scan                \ ( -- n ) nombre de peripheriques USB
    ." [usb-hid] peripheriques USB : " u. cr
    xhci-souris? if
        ." [usb-hid] souris USB detectee" cr
    else
        ." [usb-hid] pas de souris USB" cr
    then
    s" HID USB actif" drv:ok
    -1
;

\ --- drv:fini  ( -- ) ---------------------------------------------------------
: drv:fini  ( -- )
;

\ --- Enregistrement -----------------------------------------------------------
drv:register
