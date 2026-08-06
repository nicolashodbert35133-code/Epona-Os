\ ╔══════════════════════════════════════════════════════════════╗
\ ║ DRIVER EPONA — Epona OS 2.0                                ║
\ ╠══════════════════════════════════════════════════════════════╣
\ ║ Nom:        bochs-vga                                      ║
\ ║ Version:    0.1.0                                           ║
\ ║ Auteur:     Epona Team                                      ║
\ ║ License:    MIT                                             ║
\ ║ Description: Bochs/QEMU VGA - framebuffer simple           ║
\ ║             (exemple QEMU du guide §11 post-implémentation) ║
\ ║                                                             ║
\ ║ Materiel supporte (PCI vendor:device) :                     ║
\ ║   1234:1111  Bochs VGA (QEMU)                              ║
\ ║                                                             ║
\ ║ Classe PCI:  03:00 (VGA compatible)                         ║
\ ║ Requiert:    rien (utilise le framebuffer GOP UEFI)         ║
\ ║ Statut:      testing                                        ║
\ ╚══════════════════════════════════════════════════════════════╝
\
\ Driver exemple pour la VM QEMU : le périphérique Bochs VGA expose un
\ framebuffer qui est déjà mappé par le GOP UEFI. On rapporte simplement
\ sa géométrie via les primitives gfb-* (800-805).

cr ." [DRV] chargement bochs-vga..." cr

s" bochs-vga" drv:name!
0 1 0 drv:version!
s" MIT" drv:license!
s" Bochs/QEMU VGA - framebuffer simple (exemple)" drv:desc!

\ --- Type du driver : Gpu ------------------------------------------------------
6 drv:type!

\ --- ID PCI du Bochs VGA -------------------------------------------------------
pci:add-id 0x1234 0x1111
pci:add-class 0x03 0x00

\ --- Informations framebuffer --------------------------------------------------
\ Affiche la géométrie GOP (adresse, largeur, hauteur, stride, bpp).
: bochs-fbinfo  ( -- )
    cr
    ." === Bochs VGA framebuffer ===" cr
    ."  Addr:   " gfb-addr hex u. decimal cr
    ."  Largeur: " gfb-width u. cr
    ."  Hauteur: " gfb-height u. cr
    ."  Stride:  " gfb-stride u. cr
    ."  Bpp:     " gfb-bpp u. cr
    cr
;

\ --- drv:probe  ( bar bus dev func -- ok? ) -----------------------------------
\ Vérifie le vendor ID PCI (le Bochs VGA peut ne pas avoir de BAR mappée).
: drv:probe  ( bar bus dev func -- ok? ) { bar bus dev func }
    bus dev func 0 pci:read-cfg16   \ ( -- vid )
    dup 0xFFFF = if
        drop
        s" bochs-vga: aucun peripherique" drv:warn
        0
    else
        0x1234 = if
            -1
        else
            s" bochs-vga: vendor non Bochs" drv:warn
            0
        then
    then
;

\ --- drv:init  ( bar bus dev func -- ok? ) -------------------------------------
\ Rapporte la géométrie du framebuffer et marque le driver actif.
: drv:init  ( bar bus dev func -- ok? ) { bar bus dev func }
    bochs-fbinfo
    s" Framebuffer Bochs VGA pret" drv:ok
    -1
;

\ --- drv:fini  ( -- ) ----------------------------------------------------------
: drv:fini  ( -- )
    s" Bochs VGA desactive" drv:ok
;

\ --- Enregistrement ------------------------------------------------------------
drv:register
