\ ============================================================================
\ forth/core2012/jour4.fth - Tests de base
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 4
\ Pile, arithmetique, comparaison. Section A (verte) : pile (dup drop swap
\ over rot nip 2dup 2drop 2swap 2over ?dup pick), arithmetique (+ - * / mod
\ /mod 1+ 1- 2* 2/ abs negate min max), logique (and or xor invert lshift
\ rshift positif). Les comparaisons (Section B) sont traitees au Jour 8.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour4.fth   (dans qemu_img)
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
\ PILE
\ ---------------------------------------------------------------------------
5 dup 5 = verif
5 3 drop 5 = verif
1 2 swap 1 = verif
1 2 3 over 2 = verif
1 2 3 rot 1 = verif
1 2 nip 2 = verif
1 2 2dup 2 = verif
1 2 3 2drop 1 = verif
1 2 3 4 2swap 2 = verif
1 2 3 4 2over 2 = verif
0 ?dup 0 = verif
7 ?dup 7 = verif
1 2 3 0 pick 3 = verif
1 2 3 2 pick 1 = verif

\ ---------------------------------------------------------------------------
\ ARITHMETIQUE
\ ---------------------------------------------------------------------------
3 4 + 7 = verif
10 4 - 6 = verif
6 2 * 12 = verif
7 2 / 3 = verif
7 2 mod 1 = verif
7 2 /mod 3 = verif 1 = verif
5 1+ 6 = verif
5 1- 4 = verif
5 2* 10 = verif
4 2/ 2 = verif
-5 abs 5 = verif
5 negate -5 = verif
3 4 min 3 = verif
3 4 max 4 = verif

\ ---------------------------------------------------------------------------
\ LOGIQUE BIT A BIT
\ ---------------------------------------------------------------------------
3 5 and 1 = verif
3 5 or 7 = verif
3 5 xor 6 = verif
0 invert -1 = verif
1 2 lshift 4 = verif
16 2 rshift 4 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 4
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour4.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
