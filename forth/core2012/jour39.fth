\ ============================================================================
\ forth/core2012/jour39.fth - M* et */MOD
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 39
\ m*/ */mod ajoutes (prims 394/395, i128). Famille corrigee en i128/u128 :
\ */ (312) calculait le produit intermediaire en i64 (overflow) ; um*
\ (321) codait hi=0 en dur ; um/mod (322) reconstruisait en 32 bits.
\ Division symetrique ; diviseur nul / quotient hors limites -> message +
\ ( 0 0 ). Section B24 : produit signe / 2^64, reste, diviseur nul,
\ hors limites.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour39.fth   (dans qemu_img)
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
\ B24 - M* : produit signe (d = lo hi, hi au sommet)
\ ---------------------------------------------------------------------------
-5 3 m*
-1 = verif
-15 = verif
65536 65536 m*
0 = verif
4294967296 = verif

\ ---------------------------------------------------------------------------
\ B24 - */MOD ( n1 n2 n3 -- rem quot )
\ ---------------------------------------------------------------------------
7 2 3 */mod
2 = verif
4 = verif

\ ---------------------------------------------------------------------------
\ B24 - */ ( n1 n2 n3 -- n )  : 10*3/4 = 7
\ ---------------------------------------------------------------------------
10 3 4 */ 7 = verif
-10 3 4 */ -7 = verif

\ ---------------------------------------------------------------------------
\ B24 - UM* / UM/MOD (non signe)
\ ---------------------------------------------------------------------------
-1 -1 um*
-1 = verif
1 = verif
7 0 2 um/mod
1 = verif
3 = verif

\ ---------------------------------------------------------------------------
\ B24 - diviseur nul -> ( 0 0 )
\ ---------------------------------------------------------------------------
7 2 0 */mod
0 = verif
0 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 39
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour39.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
