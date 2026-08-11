\ ============================================================================
\ forth/core2012/jour25.fth - HERE, ALLOT, ,, C,
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 25
\ Relation cohérente avec l'unite d'adresse (1 AU = 1 cellule i64 :
\ ALLOT n -> +n, , / c, -> +1, ALIGNED = identite). Bornage strict
\ MAX_MEM=65536 sur allot, , / c, et create : message au depassement.
\ ALLOT negatif via saturating_sub (plus de wrap 64 bits -> plus de
\ resize geant/OOM). Section B11 : alignement, increment +1, allot
\ negatif, , / c, stockage + delta, depassement 65536 bloque
\ (here inchange).
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour25.fth   (dans qemu_img)
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
\ B11 - ALLOT positif : +n
\ ---------------------------------------------------------------------------
here 4 allot here swap - 4 = verif
here 100 allot here swap - 100 = verif

\ ---------------------------------------------------------------------------
\ B11 - ALLOT negatif : -n (saturating_sub)
\ ---------------------------------------------------------------------------
here 6 allot here 6 - allot here swap - 0 = verif

\ ---------------------------------------------------------------------------
\ B11 - , / C, : stockage + increment +1
\ ---------------------------------------------------------------------------
here 1234 , here swap - 1 = verif
here 65 c, here swap - 1 = verif
here 0 1234 , @ 1234 = verif

\ ---------------------------------------------------------------------------
\ B11 - depassement 65536 bloque : here inchange
\ ---------------------------------------------------------------------------
here 70000 allot here = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 25
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour25.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
