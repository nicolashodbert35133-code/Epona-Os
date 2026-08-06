\ ╔══════════════════════════════════════════════════════════════╗
\ ║ DRIVER EPONA — Epona OS 2.0                                ║
\ ╠══════════════════════════════════════════════════════════════╣
\ ║ Nom:        pcspkr                                         ║
\ ║ Version:    0.1.0                                           ║
\ ║ Auteur:     Epona Team                                      ║
\ ║ License:    MIT                                             ║
\ ║ Description: Haut-parleur PC (beeper, timer PIT 8254)       ║
\ ║                                                             ║
\ ║ Materiel supporte (PCI vendor:device) :                     ║
\ ║   aucun — haut-parleur standard PC (ports 0x42/0x43/0x61)   ║
\ ║                                                             ║
\ ║ Classe PCI:  —                                               ║
\ ║ Requiert:    rien                                           ║
\ ║ Statut:      stable                                         ║
\ ╚══════════════════════════════════════════════════════════════╝
\
\ Driver non-PCI. Expose `pcspkr:beep ( freq ms -- )` pour emettre un
\ bip sur le haut-parleur interne via la primitive `beep`.
\ Primitives : beep ( freq ms -- ).

cr ." [DRV] chargement pcspkr..." cr

s" pcspkr" drv:name!
0 1 0 drv:version!
s" MIT" drv:license!
s" Haut-parleur PC (beeper)" drv:desc!

\ --- Type du driver : Generic ------------------------------------------------
0 drv:type!

\ --- drv:probe  ( bar bus dev func -- ok? ) ---------------------------------
\ Le beeper est toujours present sur un PC : retourne TRUE.
: drv:probe  ( bar bus dev func -- ok? ) { bar bus dev func }
    -1
;

\ --- API publique -------------------------------------------------------------
\ pcspkr:beep ( freq ms -- ) : emet un bip de frequence `freq` Hz pendant
\ `ms` millisecondes.
: pcspkr:beep  ( freq ms -- )
    beep
;

\ --- drv:init  ( bar bus dev func -- ok? ) -----------------------------------
\ Enregistre le driver. Pas de bip automatique au boot (discret).
: drv:init  ( bar bus dev func -- ok? ) { bar bus dev func }
    s" pcspkr actif" drv:ok
    -1
;

\ --- drv:fini  ( -- ) ---------------------------------------------------------
: drv:fini  ( -- )
;

\ --- Enregistrement -----------------------------------------------------------
drv:register
