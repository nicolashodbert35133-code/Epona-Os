\ ╔══════════════════════════════════════════════════════════════╗
\ ║ DRIVER EPONA — Epona OS 2.0                                ║
\ ╠══════════════════════════════════════════════════════════════╣
\ ║ Nom:        amd-ryzen5-5500u                               ║
\ ║ Version:    0.1.0                                           ║
\ ║ Auteur:     Epona Team                                      ║
\ ║ License:    MIT                                             ║
\ ║ Description: AMD Ryzen 5 5500U (Cezanne APU) — Root         ║
\ ║             Complex / informations CPU                      ║
\ ║                                                             ║
\ ║ Materiel supporte (PCI vendor:device) :                     ║
\ ║   1022:1631  AMD Cezanne (Root Complex)                    ║
\ ║                                                             ║
\ ║ Classe PCI:  06:00 (Host bridge)                            ║
\ ║ Requiert:    rien                                           ║
\ ║ Statut:      testing                                        ║
\ ╚══════════════════════════════════════════════════════════════╝
\
\ Driver du Root Complex AMD : identifie la plateforme et rapporte les
\ infos CPU (CPUID). Primitives : cpuid ( eax -- eax ebx ecx edx ),
\ msr@ ( ecx -- edx eax ), pci:read-cfg16 ( bus dev fn off -- u16 ).

cr ." [DRV] chargement amd-ryzen5-5500u..." cr

s" amd-ryzen5-5500u" drv:name!
0 1 0 drv:version!
s" MIT" drv:license!
s" AMD Ryzen 5 5500U (Cezanne APU) - Root Complex" drv:desc!

\ --- Type du driver : Generic (chipset) --------------------------------------
0 drv:type!

\ --- ID PCI du Root Complex Cezanne ------------------------------------------
pci:add-id 0x1022 0x1631
pci:add-class 0x06 0x00

\ --- Informations CPU (CPUID) -------------------------------------------------
: amd-ryzen-cpuinfo  ( -- )
    cr
    ." === AMD Ryzen 5 5500U ===" cr
    ."  Marque:      AMD" cr
    ."  Puce:        Cezanne - Zen 2 - 7nm" cr
    ."  Vendor ID:   1022h" cr
    ."  Device ID:   1631h (Root Complex)" cr
    cr
    ."  CPUID:" cr
    1 cpuid                 \ ( eax ebx ecx edx )
    drop drop drop          \ ( eax )
    ."    Stepping:  " 0xF and u. cr
    1 cpuid drop drop drop  \ ( eax )
    ."    Family:    " 8 rshift 0xF and u. cr
    1 cpuid drop drop drop  \ ( eax )
    ."    Model:     " 4 rshift 0xF and u. cr
    cr
    ."  Coeurs:       6 physiques / 12 threads" cr
    ."  Base:         2.1 GHz" cr
    ."  Boost:        4.0 GHz" cr
    ."  TDP:          15W (12-25W configurable)" cr
    ."  L2:           512 Ko par coeur" cr
    ."  L3:           8 Mo partage" cr
    ."  RAM:          DDR4-3200 dual channel" cr
    cr
;

\ --- Registres MSR (lecture seule, optionnel) --------------------------------
: amd-ryzen-msr-dump  ( -- )
    cr
    ." === AMD Ryzen 5 5500U - Registres MSR ===" cr
    ."  0xC0010010 (SYSCFG):    " hex 0xC0010010 msr@ hex u. decimal cr
    ."  0xC0010015 (HWCR):      " hex 0xC0010015 msr@ hex u. decimal cr
    ."  0xC0010064 (PStateDef0): " hex 0xC0010064 msr@ hex u. decimal cr
    ."  0xC0010065 (PStateDef1): " hex 0xC0010065 msr@ hex u. decimal cr
    ."  0xC0010292 (HW_CFG):     " hex 0xC0010292 msr@ hex u. decimal cr
    ."  0xC0010293 (BoostLimit): " hex 0xC0010293 msr@ hex u. decimal cr
    cr
;

\ --- drv:probe  ( bar bus dev func -- ok? ) ---------------------------------
\ Le Root Complex n'a souvent pas de BAR : on verifie le vendor ID PCI.
: drv:probe  ( bar bus dev func -- ok? ) { bar bus dev func }
    bus dev func 0 pci:read-cfg16   \ ( -- vid )
    dup 0xFFFF = if
        drop
        s" amd-ryzen5-5500u: aucun peripherique" drv:warn
        0
    else
        0x1022 = if
            -1
        else
            s" amd-ryzen5-5500u: vendor non AMD" drv:warn
            0
        then
    then
;

\ --- drv:init  ( bar bus dev func -- ok? ) -----------------------------------
\ Rapporte les infos plateforme/CPU puis marque le driver actif.
: drv:init  ( bar bus dev func -- ok? ) { bar bus dev func }
    amd-ryzen-cpuinfo
    s" Root Complex AMD detecte" drv:ok
    -1
;

\ --- drv:fini  ( -- ) ---------------------------------------------------------
: drv:fini  ( -- )
    s" Root Complex AMD desenregistre" drv:ok
;

\ --- Enregistrement -----------------------------------------------------------
drv:register
