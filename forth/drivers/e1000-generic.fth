\ ╔══════════════════════════════════════════════════════════════╗
\ ║ DRIVER EPONA — Epona OS 2.0                                ║
\ ╠══════════════════════════════════════════════════════════════╣
\ ║ Nom:        e1000-generic                                   ║
\ ║ Version:    0.1.0                                           ║
\ ║ Auteur:     Epona Team                                      ║
\ ║ License:    MIT                                             ║
\ ║ Description: Carte reseau Intel PRO/1000 generique          ║
\ ║             (8254x/8257x/8258x, I217/I218/I219)             ║
\ ║                                                             ║
\ ║ Materiel supporte (PCI vendor:device) :                     ║
\ ║   8086:1000 82542, 8086:100E 82540EM, 8086:100F 82545EM    ║
\ ║   8086:105E 82571EB, 8086:10BC 82574L, 8086:1502 82579LM   ║
\ ║   8086:153A I217V, 8086:1559 I219LM, ... (voir pci:add-id) ║
\ ║                                                             ║
\ ║ Classe PCI:  02:00 (Ethernet)                               ║
\ ║ Requiert:    rien                                           ║
\ ║ Statut:      experimental                                   ║
\ ╚══════════════════════════════════════════════════════════════╝
\
\ S'appuie sur l'init reseau Rust (primitives net:*).
\ Primitives : net:e1000:init ( bar -- ok? ), net:init ( -- ok? ),
\              net:mac ( -- ... ), net:status ( -- link_up? ).

cr ." [DRV] chargement e1000-generic..." cr

s" e1000-generic" drv:name!
0 1 0 drv:version!
s" MIT" drv:license!
s" Carte reseau Intel PRO/1000 generique" drv:desc!

\ --- Type du driver : Network ------------------------------------------------
1 drv:type!

\ --- IDs Intel e1000/e1000e (vendor 0x8086) ----------------------------------
pci:add-id 0x8086 0x1000   \ 82542
pci:add-id 0x8086 0x100E   \ 82540EM
pci:add-id 0x8086 0x100F   \ 82545EM
pci:add-id 0x8086 0x101D   \ 82546EB
pci:add-id 0x8086 0x101E   \ 82540EP
pci:add-id 0x8086 0x1026   \ 82545EP
pci:add-id 0x8086 0x1075   \ 82547GI
pci:add-id 0x8086 0x1076   \ 82541GI
pci:add-id 0x8086 0x105E   \ 82571EB
pci:add-id 0x8086 0x10A7   \ 82575EB
pci:add-id 0x8086 0x10BC   \ 82574L
pci:add-id 0x8086 0x10BD   \ 82574L
pci:add-id 0x8086 0x10D3   \ 82574L (Gigabit Express)
pci:add-id 0x8086 0x10E8   \ 82576
pci:add-id 0x8086 0x10F0   \ 82577LC
pci:add-id 0x8086 0x10F1   \ 82577LM
pci:add-id 0x8086 0x1502   \ 82579LM
pci:add-id 0x8086 0x1503   \ 82579V
pci:add-id 0x8086 0x153A   \ I217V
pci:add-id 0x8086 0x153B   \ I218LM
pci:add-id 0x8086 0x153C   \ I218V
pci:add-id 0x8086 0x1559   \ I219LM
pci:add-id 0x8086 0x155A   \ I219V

\ --- Classe Ethernet (fallback) ----------------------------------------------
pci:add-class 0x02 0x00

\ --- drv:probe  ( bar bus dev func -- ok? ) ---------------------------------
: drv:probe  ( bar bus dev func -- ok? ) { bar bus dev func }
    bar 0= if
        s" e1000-generic: BAR0 nulle" drv:warn
        0
    else
        -1
    then
;

\ --- drv:init  ( bar bus dev func -- ok? ) -----------------------------------
\ Initialise la carte via crate::net et rapporte l'etat du lien.
: drv:init  ( bar bus dev func -- ok? ) { bar bus dev func }
    bar net:e1000:init if
        net:status if
            ." [e1000] lien actif" cr
        else
            ." [e1000] lien inactif (cable ?)" cr
        then
        s" e1000 initialise" drv:ok
        -1
    else
        s" e1000-generic: echec init reseau" drv:err
        0
    then
;

\ --- drv:fini  ( -- ) ---------------------------------------------------------
: drv:fini  ( -- )
    s" e1000 arrete" drv:ok
;

\ --- Enregistrement -----------------------------------------------------------
drv:register
