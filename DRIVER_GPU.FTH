\ ============================================================
\ DRIVER_GPU.FTH — Pilote Graphique AMD Radeon
\ PCI: 03:00.0  V1002 D164c  class 03 subclass 00
\ ============================================================
\ Enveloppe les primitives Rust gpu:* en mots Forth
\ utilisateur-friendly avec gestion d'etat et messages.
\
\ Charger : require DRIVER_GPU.FTH
\ Ou :     sys:load DRIVER_GPU.FTH
\ ============================================================

cr ." [GPU] Chargement pilote graphique AMD Radeon..." cr

\ ── Variables d'etat ─────────────────────────────────────────
variable gpu-ok       0 gpu-ok !
variable gpu-w        0 gpu-w !
variable gpu-h        0 gpu-h !
variable gpu-bpp      0 gpu-bpp !

\ ── Initialisation ───────────────────────────────────────────
: gpu-drive-init ( -- ok? )
    cr ." [GPU] Detection AMD Radeon (PCI 03:00.0)..." cr
    gpu:init
    dup if
        1 gpu-ok !
        gpu:resolution
        gpu-h ! gpu-w !
        ." [GPU] Resolution : " gpu-w @ . ." x" gpu-h @ . cr
        ." [GPU] Accel HW  : " gpu:accel? if ." OUI" else ." NON" then cr
    else
        0 gpu-ok !
        ." [GPU] Aucun GPU detecte" cr
    then
;

\ ── Dimensions ───────────────────────────────────────────────
: gpu-width  ( -- w ) gpu-w @ ;
: gpu-height ( -- h ) gpu-h @ ;

\ ── Dessin ───────────────────────────────────────────────────
: gpu-remplir ( color -- )
    gpu-w @ gpu-h @ 0 0 2swap gpu:fill
;

: gpu-rectangle ( x y w h color -- )
    gpu:fill
;

\ ── Flip / VSync ─────────────────────────────────────────────
: gpu-present ( -- )
    gpu:flip
;

: gpu-wait-vsync ( -- )
    gpu:vsync
;

\ ── Framebuffer brut ─────────────────────────────────────────
: gpu-fb ( -- addr )
    gpu:fb-addr
;

: gpu-pas ( -- stride )
    gpu:fb-stride
;

\ ── Curseur ──────────────────────────────────────────────────
: gpu-curseur ( addr -- )
    gpu:cursor
;

\ ── Multi-ecran ──────────────────────────────────────────────
: gpu-ecrans ( -- n )
    gpu:outputs
;

: gpu-ecran-info ( idx -- )
    gpu:output-info
;

\ ── Infos ────────────────────────────────────────────────────
: gpu-info-display ( -- )
    cr ." ╔═══════════════════════════════════╗" cr
    ." ║  GPU — AMD Radeon                  ║" cr
    ." ╚═══════════════════════════════════╝" cr
    gpu-ok @ 0= if
        ."  Etat : NON INITIALISE" cr
        exit
    then
    ."  Resolution : " gpu-w @ . ." x" gpu-h @ . cr
    ."  Accel HW   : " gpu:accel? if ." OUI" else ." NON" then cr
    ."  Ecrans     : " gpu:outputs . cr
    gpu:info
;

\ ── Enregistrement ───────────────────────────────────────────
sys:register gpu

\ ── Init auto ────────────────────────────────────────────────
gpu-drive-init drop

cr ." [GPU] Pilote charge. Mots :" cr
."   gpu-drive-init  ( -- ok? )     initialiser" cr
."   gpu-remplir     ( color -- )   remplir ecran" cr
."   gpu-rectangle   ( x y w h c -- ) rectangle" cr
."   gpu-present     ( -- )         flip buffer" cr
."   gpu-width       ( -- w )       largeur" cr
."   gpu-height      ( -- h )       hauteur" cr
."   gpu-fb          ( -- addr )    addr framebuffer" cr
."   gpu-pas         ( -- stride )  pas ligne" cr
."   gpu-info-display( -- )         afficher infos" cr
."   gpu-ecrans      ( -- n )       nb ecrans" cr
cr
