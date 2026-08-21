( ============================================================================
forth/core2012/jour61.fth - ROLL / 2R@

Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 61
ROLL ( x_u ... x_1 x_0 u -- x_{u-1} ... x_0 x_u ) : remonte la u-ieme
cellule au sommet. 1 ROLL = SWAP, 2 ROLL = ROT, 0 ROLL = no-op.
2R@ ( -- x1 x2 ) ( R: x1 x2 -- x1 x2 ) : copie la paire de cellules du
sommet du return stack vers la pile de donnees (sans depiler).

Conventions Epona :
  - chaque test imprime sa VALEUR REELLE via '.'
  - '\ -1' = test OK,  '\ 0' = echec
  - '... = verif' compte les echecs dans NB-FAILS (auto)
  - lancement : exec forth/core2012/jour61.fth   (dans qemu_img)

PERIMETRE : uniquement des mots Forth 2012 (CORE / CORE EXT).
============================================================================ )
variable NB-FAILS
0 NB-FAILS !

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

( --- ROLL - 0 roll = no-op --- )
1 2 3 0 roll
3 = verif 2 = verif 1 = verif

( --- ROLL - 1 roll = swap --- )
1 2 3 1 roll
2 = verif 3 = verif 1 = verif

( --- ROLL - 2 roll = rot --- )
1 2 3 2 roll
1 = verif 3 = verif 2 = verif

( --- ROLL - n >= taille de pile : condition ambigue, pile inchangee --- )
1 2 3 5 roll
3 = verif 2 = verif 1 = verif

( --- 2R@ - copie la paire du return stack --- )
: t61a ( -- 2 1 ) 1 2 >r >r 2r@ ;
t61a
1 = verif 2 = verif

( --- 2R@ - ne depile pas le return stack --- )
: t61b ( -- 2 1 2 1 ) 1 2 >r >r 2r@ 2r@ ;
t61b
1 = verif 2 = verif 1 = verif 2 = verif

( --- 2R@ - 2r@ a copie AVANT que 2r> ne depile --- )
: t61c ( -- 2 1 2 1 ) 1 2 >r >r 2r@ 2r> ;
t61c
1 = verif 2 = verif 1 = verif 2 = verif

( --- RESUME JOURNEE 61 --- )
cr
." ==========================" cr
." jour61.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
