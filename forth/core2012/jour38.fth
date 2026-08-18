\ ============================================================================
\ forth/core2012/jour38.fth - U< et S>D
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 38
\ u</s>d absents -> prims 392/393. u< : comparaison non signee via
\ as u64, flag -1/0 (Jour 8). s>d : extension de signe, peek le sommet
\ et pousse hi = 0/-1 (d = ( lo hi ), coherent avec 2@/2! du Jour 37).
\ Section B23 : limites 0 -1 / -1 0 / -1 -1, contraste < vs u<,
\ extension de signe, aller-retour 2!/2@.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour38.fth   (dans qemu_img)
\
\ PERIMETRE : uniquement des mots Forth 2012 (CORE / CORE EXT).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !
variable d38

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ ---------------------------------------------------------------------------
\ B23 - U< : limites signees/non signees
\ ---------------------------------------------------------------------------
0 -1 u< -1 = verif
-1 0 u< 0 = verif
-1 -1 u< 0 = verif
-1 1 u< 0 = verif
1 -1 u< -1 = verif
5 5 u< 0 = verif

\ ---------------------------------------------------------------------------
\ B23 - contraste < (signe) vs u< (non signe)
\ ---------------------------------------------------------------------------
-1 1 < -1 = verif
-1 1 u< 0 = verif

\ ---------------------------------------------------------------------------
\ B23 - S>D : extension de signe (hi = 0 / -1)
\ ---------------------------------------------------------------------------
5 s>d
0 = verif
5 = verif
-5 s>d
-1 = verif
-5 = verif
0 s>d
0 = verif
0 = verif

\ ---------------------------------------------------------------------------
\ B23 - aller-retour 2! / 2@
\ ---------------------------------------------------------------------------
7 -8 d38 2!
d38 2@
-8 = verif
7 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 38
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour38.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
