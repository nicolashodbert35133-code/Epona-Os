\ ============================================================================
\ jour61_debug.fth - Debug pas a pas pour jour61
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

cr ." --- ROLL 0 (expect 3 x -1) ---" cr
1 2 3 0 roll
3 = verif 2 = verif 1 = verif

cr ." --- ROLL 1 (expect 3 x -1) ---" cr
1 2 3 1 roll
2 = verif 3 = verif 1 = verif

cr ." --- ROLL 2 (expect 3 x -1) ---" cr
1 2 3 2 roll
1 = verif 3 = verif 2 = verif

cr ." --- ROLL 5 (expect 3 x -1) ---" cr
1 2 3 5 roll
3 = verif 2 = verif 1 = verif

cr ." --- t61a (expect 2 x -1) ---" cr
1 2 >r >r 2r@
1 = verif 2 = verif

cr ." --- t61b (expect 4 x -1) ---" cr
1 2 >r >r 2r@ 2r@
1 = verif 2 = verif 1 = verif 2 = verif

cr ." --- t61c (expect 4 x -1) ---" cr
1 2 >r >r 2r@ 2r>
1 = verif 2 = verif 1 = verif 2 = verif

cr ." ==========================" cr
." jour61_debug - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
