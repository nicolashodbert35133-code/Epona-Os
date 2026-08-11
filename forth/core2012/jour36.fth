\ ============================================================================
\ forth/core2012/jour36.fth - BASE et ALIGN
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 36
\ base etait un champ Rust non adressable. Correctif : nouvelle cellule
\ systeme base_addr = MAX_MEM - 3 = 65533 (init 10), source de verite
\ unique ; helper cur_base() lit memory[base_addr]. . / u. / hex / decimal
\ / parsing passent par cur_base(). Primitives : base = 388 (pousse
\ base_addr), align = 389 (no-op : 1 AU = 1 cellule -> toujours aligne).
\ Section B21 : BASE adressable/modifiable, parsing hex/binaire,
\ ALIGN no-op.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour36.fth   (dans qemu_img)
\
\ PERIMETRE : uniquement des mots Forth 2012 (CORE / CORE EXT).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !
variable num36

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ ---------------------------------------------------------------------------
\ B21 - BASE adressable et modifiable
\ ---------------------------------------------------------------------------
base @ 10 = verif
base 65533 = verif

\ ---------------------------------------------------------------------------
\ B21 - parsing en base 2
\ ---------------------------------------------------------------------------
2 base !
s" 1010" evaluate num36 !
10 base !
num36 @ 10 = verif

\ ---------------------------------------------------------------------------
\ B21 - parsing en base 16
\ ---------------------------------------------------------------------------
16 base !
s" FF" evaluate num36 !
10 base !
num36 @ 255 = verif

\ ---------------------------------------------------------------------------
\ B21 - ALIGN no-op (1 AU = 1 cellule -> toujours aligne)
\ ---------------------------------------------------------------------------
1 aligned 1 = verif
5 aligned 5 = verif
123 aligned 123 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 36
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour36.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
