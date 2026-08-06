\ ╔══════════════════════════════════════════════════════════════╗
\ ║ DRIVER EPONA — Epona OS 2.0                                ║
\ ╠══════════════════════════════════════════════════════════════╣
\ ║ Nom:        generic-hda                                     ║
\ ║ Version:    0.1.0                                           ║
\ ║ Auteur:     Epona Team                                      ║
\ ║ License:    MIT                                             ║
\ ║ Description: Audio High Definition generique (Intel/AMD/    ║
\ ║             NVIDIA)                                          ║
\ ║                                                             ║
\ ║ Materiel supporte (PCI vendor:device) :                     ║
\ ║   tous les controleurs HDA (classe 04:03)                   ║
\ ║                                                             ║
\ ║ Classe PCI:  04:03 (HDA)                                    ║
\ ║ Requiert:    rien                                           ║
\ ║ Statut:      experimental                                   ║
\ ╚══════════════════════════════════════════════════════════════╝
\
\ NOTE : dans cette branche, l'init Rust crate::hda est un stub qui
\ retourne 0. Ce driver assure la DETECTION du controleur (classe 04:03)
\ et l'enregistrement ; la lecture audio viendra avec l'init Rust complet.
\ Primitives : hda:init ( bar -- ok? ), hda:stream-count ( bar -- n ),
\              hda:output-pin ( bar -- widget-nid ), hda-beep ( freq ms -- ).

cr ." [DRV] chargement generic-hda..." cr

s" generic-hda" drv:name!
0 1 0 drv:version!
s" MIT" drv:license!
s" Audio High Definition generique" drv:desc!

\ --- Type du driver : Audio ---------------------------------------------------
2 drv:type!

\ --- Classe HDA ---------------------------------------------------------------
pci:add-class 0x04 0x03

\ --- drv:probe  ( bar bus dev func -- ok? ) ---------------------------------
: drv:probe  ( bar bus dev func -- ok? ) { bar bus dev func }
    bar 0= if
        s" generic-hda: BAR0 nulle" drv:warn
        0
    else
        -1
    then
;

\ --- drv:init  ( bar bus dev func -- ok? ) -----------------------------------
\ Detecte le controleur HDA, rapporte la BAR et le nombre de streams.
\ Retourne -1 (controleur present) meme si l'init Rust est un stub.
: drv:init  ( bar bus dev func -- ok? ) { bar bus dev func }
    ." [hda] BAR0 = " bar hex u. decimal cr
    bar hda:stream-count
    ." [hda] streams : " u. cr
    bar hda:init if
        s" HDA initialise" drv:ok
    else
        s" generic-hda: init Rust minimal (stub), controleur present" drv:warn
    then
    -1
;

\ --- drv:fini  ( -- ) ---------------------------------------------------------
: drv:fini  ( -- )
    s" HDA arrete" drv:ok
;

\ --- Enregistrement -----------------------------------------------------------
drv:register
