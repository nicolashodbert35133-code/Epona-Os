\ ╔══════════════════════════════════════════════════════════════╗
\ ║ DRIVER EPONA — Epona OS 2.0                                ║
\ ╠══════════════════════════════════════════════════════════════╣
\ ║ Nom:        generic-simplefb                                ║
\ ║ Version:    0.1.0                                           ║
\ ║ Auteur:     Epona Team                                      ║
\ ║ License:    MIT                                             ║
\ ║ Description: Framebuffer UEFI (fallback GPU universel)      ║
\ ║             Marche sur AMD/Intel/NVIDIA/QEMU.               ║
\ ║                                                             ║
\ ║ Materiel supporte (PCI vendor:device) :                     ║
\ ║   aucun en particulier — utilise le GOP UEFI deja charge    ║
\ ║                                                             ║
\ ║ Classe PCI:  03:00 (VGA), fallback si aucun driver GPU      ║
\ ║ Requiert:    rien                                           ║
\ ║ Statut:      stable                                         ║
\ ╚══════════════════════════════════════════════════════════════╝
\
\ Ce driver n'accede pas au materiel : il confirme que le framebuffer
\ UEFI (deja configure par le GOP) est disponible et enregistre la
\ resolution. C'est le fallback universel de la v1.
\
\ Primitives : fb-size ( -- w h ), fb-text ( x y addr len color scale -- ),
\              fb:blit ( sx sy w h dx dy -- ).

cr ." [DRV] chargement generic-simplefb..." cr

s" generic-simplefb" drv:name!
0 1 0 drv:version!
s" MIT" drv:license!
s" Framebuffer UEFI (fallback GPU universel)" drv:desc!

\ --- Type du driver : Gpu ----------------------------------------------------
6 drv:type!

\ --- Classe VGA/display (fallback si aucun driver GPU specifique) -----------
pci:add-class 0x03 0x00

\ --- drv:probe  ( bar bus dev func -- ok? ) ---------------------------------
\ Le framebuffer existe des que le GOP UEFI a tourne : tester fb-size.
: drv:probe  ( bar bus dev func -- ok? ) { bar bus dev func }
    fb-size                 \ ( w h ) — h sur le sommet
    swap dup 0= if          \ ( h w ) — largeur nulle ?
        2drop
        s" generic-simplefb: framebuffer vide" drv:err
        0
    else
        2drop
        -1
    then
;

\ --- drv:init  ( bar bus dev func -- ok? ) -----------------------------------
\ Affiche la resolution fournie par le GOP et marque le driver actif.
: drv:init  ( bar bus dev func -- ok? ) { bar bus dev func }
    fb-size                 \ ( w h ) — h sur le sommet
    swap                    \ ( h w ) — w sur le sommet
    ." [simplefb] framebuffer " u. ." x" u. ." px" cr
    s" Framebuffer UEFI actif" drv:ok
    -1
;

\ --- drv:fini  ( -- ) ---------------------------------------------------------
\ Rien a liberer : le framebuffer appartient au noyau.
: drv:fini  ( -- )
;

\ --- Enregistrement -----------------------------------------------------------
drv:register
