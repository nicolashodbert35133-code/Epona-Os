\ ============================================================
\ DRIVER_NVME.FTH — Pilote Stockage NVMe (WD SN770)
\ PCI: 02:00.0  V15b7 D5017  class 01 subclass 08
\ ============================================================
\ Enveloppe les primitives Rust nvme:* en mots Forth
\ utilisateur-friendly pour la gestion du disque NVMe.
\
\ Charger : require DRIVER_NVME.FTH
\ Ou :     sys:load DRIVER_NVME.FTH
\ ============================================================

cr ." [NVME] Chargement pilote NVMe..." cr

\ ── Variables d'etat ─────────────────────────────────────────
variable nvme-ok      0 nvme-ok !
variable nvme-lbasz   512 nvme-lbasz !
variable nvme-totlb   0 nvme-totlb !

\ ── Initialisation ───────────────────────────────────────────
: nvme-drive-init ( -- ok? )
    cr ." [NVME] Detection WD SN770 (PCI 02:00.0)..." cr
    nvme:init
    dup if
        1 nvme-ok !
        nvme:lba-size  nvme-lbasz !
        nvme:total-lbas nvme-totlb !
        ." [NVME] Disque initialise" cr
        nvme:info
    else
        0 nvme-ok !
        ." [NVME] Aucun disque NVMe" cr
    then
;

\ ── Taille secteur ───────────────────────────────────────────
: nvme-secteur ( -- bytes )
    nvme:lba-size
;

\ ── Taille totale ────────────────────────────────────────────
: nvme-taille ( -- bytes )
    nvme:capacity
;

\ ── Lecture ──────────────────────────────────────────────────
\ lit count secteurs depuis le LBA lba dans le buffer a addr
\ Retourne le nombre d'octets lus
: nvme-lire ( idx lba count buf-addr -- bytes )
    nvme:read
;

\ ── Ecriture ─────────────────────────────────────────────────
\ ecrit count secteurs depuis le buffer a addr vers le LBA lba
: nvme-ecrire ( idx lba count buf-addr -- bytes )
    nvme:write
;

\ ── Allocation buffer lecture ────────────────────────────────
\ Alloue un buffer de n pages physiques, retourne l'adresse
: nvme-buffer ( n-pages -- addr )
    alloc-phys
;

\ ── Liberation buffer ────────────────────────────────────────
: nvme-free ( addr n-pages -- )
    free-phys
;

\ ── Lecture d'un secteur complet (512 ou 4096 octets) ────────
\ Alloue un buffer, lit 1 secteur, retourne addr + taille
: nvme-lire-secteur ( idx lba -- addr size )
    nvme-lbasz 4096 max    \ taille allocation = max(secteur, 4096)
    4095 + 12 rshift       \ nb pages = ceil(size / 4096)
    over >r                \ save size
    dup nvme-buffer        \ alloc pages, keep addr
    r> nvme-lbasz swap     \ stack: addr pages size
    >r >r                  \ save size, pages
    1 -rot                 \ count=1, idx, lba, addr
    0 -rot                 \ idx=0
    nvme-lire drop         \ lire
    r> r>                  \ restore pages, size
;

\ ── Infos ────────────────────────────────────────────────────
: nvme-drive-info ( -- )
    cr ." ╔═══════════════════════════════════╗" cr
    ." ║  NVMe — WD SN770                   ║" cr
    ." ╚═══════════════════════════════════╝" cr
    nvme-ok @ 0= if
        ."  Etat : NON INITIALISE" cr
        exit
    then
    ."  Secteur  : " nvme-lbasz @ . ." octets" cr
    ."  LBA totaux: " nvme-totlb @ u. cr
    ."  Taille   : " nvme:capacity u. ." octets" cr
;

\ ── Enregistrement ───────────────────────────────────────────
sys:register nvme

\ ── Init auto ────────────────────────────────────────────────
nvme-drive-init drop

cr ." [NVME] Pilote charge. Mots :" cr
."   nvme-drive-init ( -- ok? )     initialiser NVMe" cr
."   nvme-lire     ( i l c a -- b )  lire secteurs" cr
."   nvme-ecrire   ( i l c a -- b )  ecrire secteurs" cr
."   nvme-secteur  ( -- bytes )       taille secteur" cr
."   nvme-taille   ( -- bytes )       taille totale" cr
."   nvme-buffer   ( n -- addr )      allouer buffer" cr
."   nvme-free     ( a n -- )         liberer buffer" cr
."   nvme-drive-info ( -- )           afficher infos" cr
cr
