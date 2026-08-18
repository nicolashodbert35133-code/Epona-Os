\ ============================================================================
\ forth/core2012/jour50.fth - WITHIN, U>, PAD
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 50
\ Les 3 mots Core Ext implementes :
\ - u> (prim 1832) : comparaison NON SIGNEE u64, flag -1/0, symetrique
\   de u< (Jour 38).
\ - within (prim 1833) : ( n lo hi -- flag ) -> -1 si lo <= n < hi
\   (borne haute EXCLUE, comparaisons signees).
\ - pad (opcode Op::Pad) : zone dediee PAD_BASE = 129936 (WORD_BASE - 1024,
\   1024 cellules sous la zone WORD). Conforme au /PAD = 1024 de
\   ENVIRONMENT? (Jour 49).
\ Section B34 : 9 cas within, 8 cas u>, 3 cas pad.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour50.fth   (dans qemu_img)
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
\ B34 - WITHIN ( n lo hi -- flag ) : lo <= n < hi
\ ---------------------------------------------------------------------------
5 0 10 within -1 = verif
0 0 10 within -1 = verif
9 0 10 within -1 = verif
10 0 10 within 0 = verif
-1 -10 10 within -1 = verif
-10 -10 10 within -1 = verif
-11 -10 10 within 0 = verif
5 5 5 within 0 = verif
5 6 5 within 0 = verif

\ ---------------------------------------------------------------------------
\ B34 - U> ( u1 u2 -- flag ) : non signe, flag -1/0
\ ---------------------------------------------------------------------------
5 3 u> -1 = verif
3 5 u> 0 = verif
-1 1 u> -1 = verif
1 -1 u> 0 = verif
-1 0 u> -1 = verif
0 -1 u> 0 = verif
-1 -1 u> 0 = verif
5 5 u> 0 = verif

\ ---------------------------------------------------------------------------
\ B34 - PAD : zone transitoire, pad + 1024 = 130960
\ ---------------------------------------------------------------------------
pad pad = verif
pad 1024 + 130960 = verif
pad 1024 0 fill
pad 3 + c@ 0 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 50
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour50.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
