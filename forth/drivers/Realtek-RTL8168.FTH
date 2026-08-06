\ ══════════════════════════════════════════════════════════
\ Realtek-RTL8168.FTH
\ Marque:   Realtek
\ Ref:      RTL8168/RTL8111 Ethernet Gigabit
\ Vendor:   10ECh (Realtek)
\ Device:   8168h
\ Standard: Gigabit Ethernet 10/100/1000 Mbps
\ Primitives: net:init, net:info, net:status, net:mac,
\             net:cards, net:dhcp, net:ping, net:arp,
\             net:ip!, net:ip@, net:gw!, net:mask!
\ ══════════════════════════════════════════════════════════

\ --- Info ---
: realtek-rtl8168-info
  cr
  cr ." === Realtek RTL8168 Ethernet ==="
  cr ."  Marque:      Realtek"
  cr ."  Ref:         RTL8168/RTL8111"
  cr ."  Vendor ID:   10ECh"
  cr ."  Device ID:   8168h"
  cr ."  Standard:    Gigabit Ethernet"
  cr ."  Débit:       10/100/1000 Mbps"
  cr
  net:info
;

\ --- Scan ---
: realtek-rtl8168-scan
  cr
  cr ." === Realtek RTL8168 SCAN ==="
  realtek-rtl8168-info
  cr
  net:init if
    cr ."  NET INIT:    OK"
  else
    cr ."  NET INIT:    ÉCHEC"
  then
  cr
  cr ."  Nombre de cartes: " net:cards u. cr
  cr ."  Statut lien: "
  net:status if
    cr ."    LIE"
  else
    cr ."    NON LIE"
  then
  cr
  cr ."  Adresse MAC:"
  net:mac
  cr ."    " hex u. decimal cr ."    " hex u. decimal cr
  cr
;

\ --- Config DHCP ---
: realtek-rtl8168-config
  cr
  cr ." === CONFIG Realtek RTL8168 — DHCP ==="
  net:dhcp if
    cr ."  DHCP:        OK"
  else
    cr ."  DHCP:        ÉCHEC"
  then
  cr
  cr ."  IP assignée:"
  net:ip@
  cr ."    " u. ." ." u. ." ." u. ." ." u. cr
  cr
;

\ --- Ping ---
: realtek-rtl8168-ping
  cr
  cr ." === TEST Realtek RTL8168 — Ping ==="
  cr ."  Ping passerelle..."
  net:ip@ drop drop drop drop
  net:ping
  if
    cr ."  Ping OK: " u. ." ms"
  else
    cr ."  Ping ÉCHEC"
  then
  cr
;

\ --- Init ---
: realtek-rtl8168-init
  cr
  cr ." --- Realtek RTL8168 INIT ---"
  realtek-rtl8168-scan
  cr ." Realtek RTL8168 init OK." cr
;
