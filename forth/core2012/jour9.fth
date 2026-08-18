\ ============================================================================
\ forth/core2012/jour9.fth - Arithmetique signee
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 9
\ Corriger 2/ pour les negatifs (v >> 1 arithmetique, arrondi vers moins
\ l'infini : -5 2/ = -3). Verifier / MOD /MOD sans reecriture : division
\ symetrique ANS (-7 3 / = -2, -7 3 MOD = -1, /MOD quotient au sommet).
\ Section B2b (bornes : MIN via -1 63 lshift, MIN+1, -1, 0, 1, -3, MAX,
\ positif) + B2b2 (division signee : preuve / mod /mod conformes).
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour9.fth   (dans qemu_img)
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
\ B2b - 2/ SIGNE (valeurs limites)
\ ---------------------------------------------------------------------------
-5 2/ -3 = verif
-1 63 lshift 2/ -1 62 lshift = verif
-1 2/ -1 = verif
0 2/ 0 = verif
1 2/ 0 = verif
-3 2/ -2 = verif
9223372036854775807 2/ 4611686018427387903 = verif
7 2/ 3 = verif

\ ---------------------------------------------------------------------------
\ B2b2 - DIVISION SIGNEE (/ MOD /MOD conformes)
\ ---------------------------------------------------------------------------
-7 3 / -2 = verif
-7 3 mod -1 = verif
-7 3 /mod -2 = verif -1 = verif
7 -3 / -2 = verif
7 -3 mod 1 = verif
12 5 /mod swap 2 = verif 2 = verif
-12 5 /mod swap -2 = verif -2 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 9
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour9.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
