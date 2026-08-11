\ ============================================================================
\ forth/core2012/jour37.fth - 2@ et 2!
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 37
\ 2@/2! etaient absents -> prims 390/391. Ordre standard Forth 2012 :
\ 2! ( x1 x2 a-addr -- ) stocke x2 a addr et x1 a addr+1 (cellule basse
\ a addr, haute a addr+1) ; 2@ ( a-addr -- x1 x2 ) empile x1 puis x2.
\ Acces via read_cell/write_cell (bornes MAX_MEM) ; hors bornes -> message
\ sandbox sans effet. Section B22 : paire, ordre, negatifs/zero, bornes.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour37.fth   (dans qemu_img)
\
\ PERIMETRE : uniquement des mots Forth 2012 (CORE / CORE EXT).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !
variable d37

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ ---------------------------------------------------------------------------
\ B22 - paire positive et ordre (x2 a addr, x1 a addr+1)
\ ---------------------------------------------------------------------------
1000 2000 d37 2!
d37 2@
2000 = verif
1000 = verif

\ ---------------------------------------------------------------------------
\ B22 - negatifs et zero
\ ---------------------------------------------------------------------------
-1 -2 d37 2!
d37 2@
-2 = verif
-1 = verif
0 0 d37 2!
d37 2@
0 = verif
0 = verif

\ ---------------------------------------------------------------------------
\ B22 - aller-retour cohérent entre 2! et 2@
\ ---------------------------------------------------------------------------
7 -8 d37 2!
d37 2@
-8 = verif
7 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 37
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour37.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
