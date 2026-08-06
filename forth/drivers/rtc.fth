\ ╔══════════════════════════════════════════════════════════════╗
\ ║ DRIVER EPONA — Epona OS 2.0                                ║
\ ╠══════════════════════════════════════════════════════════════╣
\ ║ Nom:        rtc                                             ║
\ ║ Version:    0.1.0                                           ║
\ ║ Auteur:     Epona Team                                      ║
\ ║ License:    MIT                                             ║
\ ║ Description: Horloge temps reel RTC (CMOS)                  ║
\ ║                                                             ║
\ ║ Materiel supporte (PCI vendor:device) :                     ║
\ ║   aucun — RTC CMOS fixe (ports 0x70/0x71), standard PC      ║
\ ║                                                             ║
\ ║ Classe PCI:  —                                               ║
\ ║ Requiert:    rien                                           ║
\ ║ Statut:      stable                                         ║
\ ╚══════════════════════════════════════════════════════════════╝
\
\ Driver non-PCI : il s'auto-declare dans drv:init sans peripherique
\ PCI. Primitives : cmos:time ( -- s m h ), cmos:date ( -- d m y ),
\ cmos:read ( reg -- u8 ), cmos:write ( val reg -- ).

cr ." [DRV] chargement rtc..." cr

s" rtc" drv:name!
0 1 0 drv:version!
s" MIT" drv:license!
s" Horloge temps reel RTC (CMOS)" drv:desc!

\ --- Type du driver : Generic ------------------------------------------------
0 drv:type!

\ --- Constantes registres CMOS -----------------------------------------------
0x00 constant RTC-SEC
0x02 constant RTC-MIN
0x04 constant RTC-HOUR

\ --- drv:probe  ( bar bus dev func -- ok? ) ---------------------------------
\ Le RTC CMOS est toujours present sur un PC : retourne TRUE.
: drv:probe  ( bar bus dev func -- ok? ) { bar bus dev func }
    -1
;

\ --- drv:init  ( bar bus dev func -- ok? ) -----------------------------------
\ Lit et affiche l'heure courante puis enregistre le driver.
: drv:init  ( bar bus dev func -- ok? ) { bar bus dev func }
    cmos:time               \ ( -- s m h ) — h sur le sommet
    ." [rtc] heure : " u. ." :" u. ." :" u. cr
    cmos:date               \ ( -- d m y ) — y sur le sommet
    ." [rtc] date : " u. ." /" u. ." /" u. cr
    s" RTC actif" drv:ok
    -1
;

\ --- drv:fini  ( -- ) ---------------------------------------------------------
: drv:fini  ( -- )
;

\ --- Enregistrement -----------------------------------------------------------
drv:register
