\ ============================================================
\ DRIVER_USB.FTH — Pilote USB generique (XHCI)
\ PCI: 03:00.3  V1022 D1639  class 0C subclass 03
\      03:00.4  V1022 D1639  class 0C subclass 03
\ ============================================================
\ Enveloppe les primitives Rust xhci-*/usb:* en mots Forth
\ utilisateur-friendly pour la gestion USB.
\
\ Charger : require DRIVER_USB.FTH
\ Ou :     sys:load DRIVER_USB.FTH
\ ============================================================

cr ." [USB] Chargement pilote USB XHCI..." cr

\ ── Variables d'etat ─────────────────────────────────────────
variable usb-ok       0 usb-ok !
variable usb-ndev     0 usb-ndev !
variable usb-souris-ok 0 usb-souris-ok !

\ ── Initialisation XHCI ─────────────────────────────────────
: usb-drive-init ( -- ok? )
    cr ." [USB] Detection XHCI (PCI 03:00.3/04)..." cr
    xhci-init
    dup if
        1 usb-ok !
        ." [USB] XHCI initialise" cr
    else
        0 usb-ok !
        ." [USB] Echec init XHCI" cr
    then
;

\ ── Reenumeration USB ────────────────────────────────────────
: usb-reinit ( -- ok? )
    usb:init
    dup if
        usb:devices usb-ndev !
        ." [USB] " usb-ndev @ . ." peripheriques detectes" cr
    then
;

\ ── Lister les peripheriques ─────────────────────────────────
: usb-lister ( -- )
    usb:devices
    dup 0= if
        drop
        ." [USB] Aucun peripherique" cr
    else
        ." [USB] " dup . ." peripheriques :" cr
        0 do
            ."  [" i . ." ] Slot=" .
            ." Port=" .
            ." Speed=" .
            ." PID=" hex u. decimal
            ." VID=" hex u. decimal
            ." Conf=" . cr
        loop
    then
;

\ ── Souris ───────────────────────────────────────────────────
: usb-souris-init ( -- ok? )
    xhci-init
    dup if
        xhci-souris? usb-souris-ok !
        usb-souris-ok @ if
            ." [USB] Souris USB detectee" cr
        else
            ." [USB] Pas de souris USB" cr
        then
    then
;

: usb-souris-lire ( -- dx dy btn )
    xhci-souris
;

: usb-souris? ( -- flag )
    xhci-souris?
;

\ ── Control Transfer ─────────────────────────────────────────
: usb-ctrl ( slot bmreq breq wval widx buf len -- actual )
    usb:control
;

\ ── Lecture / Ecriture ───────────────────────────────────────
: usb-lire ( slot buf len -- actual )
    usb:read
;

: usb-ecrire ( slot buf len -- actual )
    usb:write
;

\ ── Bulk Transfer ────────────────────────────────────────────
: usb-bulk-lire ( slot buf len -- actual )
    usb:bulk-read
;

: usb-bulk-ecrire ( slot buf len -- actual )
    usb:bulk-write
;

\ ── Detection rapide ─────────────────────────────────────────
: usb-scan-rapide ( -- )
    cr ." [USB] Scan rapide :" cr
    usb:devices
    0 do
        ."  Slot " i . ." : "
        ." VID=" hex . ." PID=" hex . decimal
        cr
    loop
;

\ ── Infos ────────────────────────────────────────────────────
: usb-info ( -- )
    cr ." ╔═══════════════════════════════════╗" cr
    ." ║  USB — XHCI Generic                ║" cr
    ." ╚═══════════════════════════════════╝" cr
    usb-ok @ 0= if
        ."  Etat : NON INITIALISE" cr
        exit
    then
    ."  XHCI     : ACTIF" cr
    ."  Periph.  : " usb-ndev @ . cr
    ."  Souris   : " usb-souris-ok @ if ." OUI" else ." NON" then cr
;

\ ── Enregistrement ───────────────────────────────────────────
sys:register usb

\ ── Init auto ────────────────────────────────────────────────
usb-drive-init drop

cr ." [USB] Pilote charge. Mots :" cr
."   usb-drive-init ( -- ok? )     init XHCI" cr
."   usb-reinit     ( -- ok? )     reenum USB" cr
."   usb-lister     ( -- )         lister peripheriques" cr
."   usb-souris-init( -- ok? )     init souris" cr
."   usb-souris-lire( -- dx dy b ) lire souris" cr
."   usb-souris?    ( -- flag )    souris presente?" cr
."   usb-ctrl       ( s bm bv wv wi a l -- n ) control" cr
."   usb-lire       ( s a l -- n )  interrupt read" cr
."   usb-ecrire     ( s a l -- n )  control write" cr
."   usb-bulk-lire  ( s a l -- n )  bulk read" cr
."   usb-bulk-ecrire( s a l -- n )  bulk write" cr
."   usb-info       ( -- )          afficher infos" cr
cr
