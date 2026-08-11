\ ============================================================================
\ forth/core2012/jour35.fth - Revue semaine 5 (tuck, -rot, locaux)
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 35
\ Revue S5 + correction des bugs P0/CRITIQUE du rapport independant :
\ - -rot (idx 38) : faisait comme rot -> corrige (a b c -- c a b).
\ - tuck (idx 40) : copiait le bas de pile -> corrige (a b -- b a b).
\ - Locaux { } : LocalGet/LocalSet/LocalsAlloc/LocalsFree sans ip += 1
\   -> rebouclage infini ; corrige (4 branches).
\ Section B2c remplacee par des verif verts (tuck/-rot) + B20 (locaux).
\ NB-FAILS attendu = 0.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour35.fth   (dans qemu_img)
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
\ B2c - -rot ( a b c -- c a b )
\ ---------------------------------------------------------------------------
1 2 3 -rot
2 = verif
1 = verif
3 = verif

\ ---------------------------------------------------------------------------
\ B2c - tuck ( a b -- b a b )
\ ---------------------------------------------------------------------------
1 2 tuck
2 = verif
1 = verif
2 = verif

\ ---------------------------------------------------------------------------
\ B20 - locaux { }
\ ---------------------------------------------------------------------------
: loc35 { x y } x y + ;
3 4 loc35 7 = verif
: loc35b { a b } a b - ;
10 3 loc35b 7 = verif
: loc35c { x } x 1 + ;
9 loc35c 10 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 35
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour35.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
