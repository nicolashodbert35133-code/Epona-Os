\ ╔══════════════════════════════════════════════════════════════╗
\ ║ DRIVER EPONA — Epona OS 2.0                                ║
\ ╠══════════════════════════════════════════════════════════════╣
\ ║ Nom:        wd-sn770-nvme                                   ║
\ ║ Version:    0.1.0                                           ║
\ ║ Auteur:     Epona Team                                      ║
\ ║ License:    MIT                                             ║
\ ║ Description: WD Black SN770 NVMe SSD (SanDisk 20-82-10081) ║
\ ║             PCIe Gen4 x4, Seq Read 5150 Mo/s               ║
\ ║                                                             ║
\ ║ Materiel supporte (PCI vendor:device) :                     ║
\ ║   15B7:5017  WD Black SN770                               ║
\ ║                                                             ║
\ ║ Classe PCI:  01:08 (NVMe)                                   ║
\ ║ Requiert:    rien                                           ║
\ ║ Statut:      stable                                         ║
\ ╚══════════════════════════════════════════════════════════════╝
\
\ Converti au format §7.1 (framework drvlib). S'appuie sur l'init Rust
\ crate::nvme. Primitives : nvme:init ( -- ok? ), nvme:ns-count
\ ( bar -- n ), nvme:read ( idx lba count buf -- bytes ),
\ nvme:lba-size, nvme:total-lbas, nvme:capacity ( -- lo hi ), nvme:info.

cr ." [DRV] chargement wd-sn770-nvme..." cr

s" wd-sn770-nvme" drv:name!
0 1 0 drv:version!
s" MIT" drv:license!
s" WD Black SN770 NVMe SSD" drv:desc!

\ --- Type du driver : Storage ------------------------------------------------
3 drv:type!

\ --- ID PCI du WD SN770 ------------------------------------------------------
pci:add-id 0x15B7 0x5017

\ --- Memoire persistante (create-only, voir drvlib.fth) ----------------------
create NVME-TEST-BUF 512 allot

\ --- Buffer de test : copie des donnees lues (octet par cellule) ------------
: nvme-test-read  ( -- )
    cr
    ." === WD SN770 - test lecture LBA 0 ===" cr
    0 0 1 NVME-TEST-BUF nvme:read
    dup 0= if
        drop
        ."  Echec de lecture" cr
    else
        ."  Octets lus : " u. cr
        ."  Premier octet : " NVME-TEST-BUF c@ hex u. decimal cr
    then
;

\ --- Informations -------------------------------------------------------------
: wd-sn770-info  ( -- )
    cr
    ." === WD Black SN770 NVMe ===" cr
    ."  Marque:      Western Digital" cr
    ."  Ref:         WD Black SN770" cr
    ."  Interface:   NVMe PCIe Gen4 x4" cr
    ."  Controleur:  SanDisk 20-82-10081" cr
    ."  Vitesses:    Seq Read 5150 Mo/s" cr
    ."               Seq Write 4900 Mo/s" cr
    nvme:info
    nvme:capacity
    ."  Capacite (hi lo): " u. u. ."  octets" cr
    ."  Taille LBA:  " nvme:lba-size u. ."  octets" cr
    ."  Total LBA:   " nvme:total-lbas u. cr
;

\ --- drv:probe  ( bar bus dev func -- ok? ) ---------------------------------
\ Le NVMe est present si sa BAR0 est non nulle.
: drv:probe  ( bar bus dev func -- ok? ) { bar bus dev func }
    bar 0= if
        s" wd-sn770-nvme: BAR0 nulle" drv:warn
        0
    else
        -1
    then
;

\ --- drv:init  ( bar bus dev func -- ok? ) -----------------------------------
\ Initialise le NVMe via crate::nvme et affiche les infos du disque.
: drv:init  ( bar bus dev func -- ok? ) { bar bus dev func }
    nvme:init if
        bar nvme:ns-count
        ." [wd-sn770] namespaces : " u. cr
        wd-sn770-info
        s" WD SN770 initialise" drv:ok
        -1
    else
        s" wd-sn770-nvme: echec init NVMe" drv:err
        0
    then
;

\ --- drv:fini  ( -- ) ---------------------------------------------------------
: drv:fini  ( -- )
    s" WD SN770 arrete" drv:ok
;

\ --- Enregistrement -----------------------------------------------------------
drv:register
