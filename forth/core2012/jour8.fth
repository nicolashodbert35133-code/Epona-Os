\ ============================================================================
\ forth/core2012/jour8.fth - Flags -1/0
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 8
\ Corriger = <> < > <= >= (prims 37, 58-66) et 0= 0<> 0< 0> : les 10
\ comparaisons renvoient -1 (vrai) / 0 (faux). Section B0 "Vrai/Faux".
\ true/false existent deja (-1/0). Comparaisons flottantes (f< f= f0< f0=)
\ deja conformes.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour8.fth   (dans qemu_img)
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
\ EGALITE / INEGALITE
\ ---------------------------------------------------------------------------
1 1 = -1 = verif
1 2 = 0 = verif
1 2 <> -1 = verif
2 2 <> 0 = verif

\ ---------------------------------------------------------------------------
\ COMPARAISONS STRICTES
\ ---------------------------------------------------------------------------
1 2 < -1 = verif
2 1 < 0 = verif
2 1 > -1 = verif
1 2 > 0 = verif
1 1 <= -1 = verif
2 1 <= 0 = verif
1 1 >= -1 = verif
1 2 >= 0 = verif

\ ---------------------------------------------------------------------------
\ 0= 0<> 0< 0>
\ ---------------------------------------------------------------------------
0 0= -1 = verif
5 0= 0 = verif
0 0<> 0 = verif
5 0<> -1 = verif
-1 0< -1 = verif
1 0< 0 = verif
5 0> -1 = verif
-1 0> 0 = verif
0 0> 0 = verif

\ ---------------------------------------------------------------------------
\ true / false
\ ---------------------------------------------------------------------------
true -1 = verif
false 0 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 8
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour8.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
