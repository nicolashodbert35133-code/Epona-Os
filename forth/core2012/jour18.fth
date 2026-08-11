\ ============================================================================
\ forth/core2012/jour18.fth - Correction de FIND
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 18
\ FIND (primitive 103) reecrite : lit longueur puis nom depuis une chaine
\ comptee (1 octet/cellule, format des chaines s" a l'execution) ; absent
\ -> ( c-addr 0 ), trouve -> ( xt flag ) avec flag = -1 si immediat
\ (xt = index dictionnaire). Section B6 : mot present non immediat,
\ mot absent.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour18.fth   (dans qemu_img)
\
\ PERIMETRE : uniquement des mots Forth 2012 (CORE / CORE EXT).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ ---------------------------------------------------------------------------
\ B6 - FIND : mot present (non immediat) -> xt flag 1
\ ---------------------------------------------------------------------------
\ Chaine comptee "dup" (3, d, u, p) construite octet par octet.
create fd 3 c, 100 c, 117 c, 112 c,
fd find
1 = verif
\ xt execute doit se comporter comme dup
fd find rot drop execute
5 = verif 5 = verif

\ ---------------------------------------------------------------------------
\ B6 - FIND : mot absent -> c-addr 0 (flag 0)
\ ---------------------------------------------------------------------------
create fx 4 c, 120 c, 121 c, 122 c, 113 c,
fx find
0 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 18
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour18.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
