variable NB-FAILS
0 NB-FAILS !

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

1 2 3 0 roll
3 = verif 2 = verif 1 = verif

1 2 3 1 roll
2 = verif 3 = verif 1 = verif

1 2 3 2 roll
1 = verif 3 = verif 2 = verif

1 2 3 5 roll
3 = verif 2 = verif 1 = verif

: t61a ( -- 2 1 ) 1 2 >r >r 2r@ ;
t61a
1 = verif 2 = verif

: t61b ( -- 2 1 2 1 ) 1 2 >r >r 2r@ 2r@ ;
t61b
1 = verif 2 = verif 1 = verif 2 = verif

: t61c ( -- 2 1 2 1 ) 1 2 >r >r 2r@ 2r> ;
t61c
1 = verif 2 = verif 1 = verif 2 = verif

cr
." ==========================" cr
." jour61_nocomment - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
