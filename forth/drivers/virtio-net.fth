\ ╔══════════════════════════════════════════════════════════════╗
\ ║ DRIVER EPONA — Epona OS 2.0                                ║
\ ╠══════════════════════════════════════════════════════════════╣
\ ║ Nom:        virtio-net                                     ║
\ ║ Version:    0.1.0                                           ║
\ ║ Auteur:     Epona Team                                      ║
\ ║ License:    MIT                                             ║
\ ║ Description: VirtIO réseau (exemple QEMU du guide           ║
\ ║             §11 post-implémentation)                        ║
\ ║                                                             ║
\ ║ Materiel supporte (PCI vendor:device) :                     ║
\ ║   1af4:1000  VirtIO net (QEMU, transitionnel)               ║
\ ║                                                             ║
\ ║ Classe PCI:  02:00 (Ethernet controller)                    ║
\ ║ Requiert:    pile réseau noyau (primitives net:*)           ║
\ ║ Statut:      testing                                        ║
\ ╚══════════════════════════════════════════════════════════════╝
\
\ Driver exemple pour la VM QEMU : la carte VirtIO net est détectée puis
\ initialisée via la pile réseau noyau (net:init). On rapporte l'état du
\ lien (net:status) et le nombre de cartes vues (net:cards).

cr ." [DRV] chargement virtio-net..." cr

s" virtio-net" drv:name!
0 1 0 drv:version!
s" MIT" drv:license!
s" VirtIO reseau - exemple QEMU" drv:desc!

\ --- Type du driver : Network --------------------------------------------------
1 drv:type!

\ --- ID PCI du VirtIO net ------------------------------------------------------
pci:add-id 0x1af4 0x1000
pci:add-class 0x02 0x00

\ --- Informations réseau -------------------------------------------------------
\ Rapporte l'état du lien et le nombre de cartes détectées.
: virtio-net-info  ( -- )
    cr
    ." === VirtIO reseau ===" cr
    net:init if
        ."  Init:     OK" cr
    else
        ."  Init:     echec" cr
    then
    net:status if
        ."  Lien:     up" cr
    else
        ."  Lien:     down" cr
    then
    ."  Cartes:   " net:cards u. cr
    cr
;

\ --- drv:probe  ( bar bus dev func -- ok? ) -----------------------------------
\ Vérifie le vendor ID PCI (0x1af4 = VirtIO).
: drv:probe  ( bar bus dev func -- ok? ) { bar bus dev func }
    bus dev func 0 pci:read-cfg16   \ ( -- vid )
    dup 0xFFFF = if
        drop
        s" virtio-net: aucun peripherique" drv:warn
        0
    else
        0x1af4 = if
            -1
        else
            s" virtio-net: vendor non VirtIO" drv:warn
            0
        then
    then
;

\ --- drv:init  ( bar bus dev func -- ok? ) -------------------------------------
\ Initialise la pile réseau (net:init) et rapporte l'état du lien.
: drv:init  ( bar bus dev func -- ok? ) { bar bus dev func }
    virtio-net-info
    net:init if
        s" VirtIO net initialise" drv:ok
        -1
    else
        s" VirtIO net: init noyau indisponible" drv:warn
        -1
    then
;

\ --- drv:fini  ( -- ) ----------------------------------------------------------
: drv:fini  ( -- )
    s" VirtIO net desactive" drv:ok
;

\ --- Enregistrement ------------------------------------------------------------
drv:register
