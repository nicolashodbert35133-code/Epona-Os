\ ============================================================
\ DRIVER_WIFI.FTH — Pilote Reseau / Wi-Fi RTL8821CE
\ PCI: 01:00.0  V10ec Dc821  class 02 subclass 80
\ ============================================================
\ Enveloppe les primitives Rust net:* en mots Forth
\ utilisateur-friendly pour la gestion reseau/Wi-Fi.
\
\ IMPORTANT : charger le firmware RTL8821CE AVANT net:init :
\   net:firmware
\   net:init
\   net:dhcp
\ ============================================================
\ Charger : require DRIVER_WIFI.FTH
\ Ou :     sys:load DRIVER_WIFI.FTH
\ ============================================================

cr ." [WIFI] Chargement pilote Wi-Fi RTL8821CE..." cr

\ ── Variables d'etat ─────────────────────────────────────────
variable wifi-ok       0 wifi-ok !
variable wifi-linked   0 wifi-linked !

\ ── Initialisation ───────────────────────────────────────────
\ Charge le firmware puis initialise la carte
: wifi-init ( -- ok? )
    cr ." [WIFI] Detection Realtek RTL8821CE (PCI 01:00.0)..." cr
    ." [WIFI] Chargement firmware..." cr
    net:firmware
    ." [WIFI] Initialisation carte..." cr
    net:init
    dup if
        1 wifi-ok !
        ." [WIFI] Carte initialisee" cr
    else
        0 wifi-ok !
        ." [WIFI] Aucune carte reseau" cr
    then
;

\ ── DHCP ─────────────────────────────────────────────────────
: wifi-dhcp ( -- ok? )
    net:dhcp
    dup if 1 wifi-linked ! then
;

\ ── Infos ────────────────────────────────────────────────────
: wifi-mac ( -- )
    net:mac
;

: wifi-info ( -- )
    net:info
;

: wifi-status ( -- )
    net:status
;

: wifi-carte? ( -- flag )
    net:cards 0 >
;

: wifi-link? ( -- flag )
    net:status
;

\ ── Adressage IP ─────────────────────────────────────────────
: wifi-ip! ( a b c d -- )
    net:ip!
;

: wifi-ip@ ( -- a b c d )
    net:ip@
;

: wifi-mask! ( a b c d -- )
    net:mask!
;

: wifi-gw! ( a b c d -- )
    net:gw!
;

\ ── Ping ─────────────────────────────────────────────────────
: wifi-ping ( a b c d -- )
    net:ping
;

\ ── UDP ──────────────────────────────────────────────────────
: wifi-udp-send ( data len a b c d port -- )
    net:udp-send
;

: wifi-udp-recv ( buf len -- n )
    net:udp-recv
;

\ ── TCP ──────────────────────────────────────────────────────
: wifi-tcp-connect ( a b c d port -- ok? )
    net:tcp-connect
;

: wifi-tcp-send ( data len -- )
    net:tcp-send
;

: wifi-tcp-recv ( buf len -- n )
    net:tcp-recv
;

: wifi-tcp-close ( -- )
    net:tcp-close
;

\ ── DNS ──────────────────────────────────────────────────────
: wifi-dns ( -- a b c d )
    net:dns
;

: wifi-dns! ( a b c d -- )
    net:dns!
;

\ ── Poll ─────────────────────────────────────────────────────
: wifi-poll ( -- )
    net:poll
;

\ ── ARP ──────────────────────────────────────────────────────
: wifi-arp ( a b c d -- )
    net:arp
;

\ ── Configuration rapide ─────────────────────────────────────
: wifi-connect ( -- ok? )
    wifi-init if
        wifi-dhcp if
            ." [WIFI] Connecte !" cr
            net:stack-info
            1
        else
            ." [WIFI] DHCP echoue" cr
            0
        then
    else
        0
    then
;

\ ── Enregistrement ───────────────────────────────────────────
sys:register wifi

\ ── Init auto ────────────────────────────────────────────────
wifi-init drop

cr ." [WIFI] Pilote charge. Mots :" cr
."   wifi-init       ( -- ok? )     init firmware + carte" cr
."   wifi-connect    ( -- ok? )     init + DHCP complet" cr
."   wifi-dhcp       ( -- ok? )     obtenir IP via DHCP" cr
."   wifi-mac        ( -- )         afficher MAC" cr
."   wifi-info       ( -- )         infos carte" cr
."   wifi-status     ( -- )         etat lien" cr
."   wifi-link?      ( -- flag )    en ligne?" cr
."   wifi-ip!        ( a b c d -- ) definir IP" cr
."   wifi-ip@        ( -- a b c d ) lire IP" cr
."   wifi-mask!      ( a b c d -- ) definir masque" cr
."   wifi-gw!        ( a b c d -- ) definir passerelle" cr
."   wifi-ping       ( a b c d -- ) ping" cr
."   wifi-tcp-connect( a b c d p -- ok? ) TCP connect" cr
."   wifi-tcp-send   ( d l -- )     TCP envoyer" cr
."   wifi-tcp-recv   ( b l -- n )   TCP recevoir" cr
."   wifi-tcp-close  ( -- )         TCP fermer" cr
."   wifi-dns        ( -- a b c d ) resoudre 8.8.8.8" cr
cr
