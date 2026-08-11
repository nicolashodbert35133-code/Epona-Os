\ ============================================================================
\ forth/core2012/jour23.fth - Contrat d'adressage
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 23
\ Decision : 1 unite d'adresse = 1 cellule i64 (chars larges 64 bits,
\ permis par Forth 2012). cell+ (+8 -> +1), cells (n*8 -> n), aligned
\ (align-8 -> identite) corriges ; cell/char = constantes Forth
\ (1 constant cell/char au boot). Endianness little-endian. Restriction
\ documentee : CHAR <c> parsing non supporte (utiliser [char]).
\ Section B9 : CELL, CHAR, ALIGNED, endianness.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour23.fth   (dans qemu_img)
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
\ B9 - CELL / CHAR (1 unite = 1 cellule i64)
\ ---------------------------------------------------------------------------
cell 1 = verif
char 1 = verif
cell char = verif

\ ---------------------------------------------------------------------------
\ B9 - CELL+ / CELLS / ALIGNED
\ ---------------------------------------------------------------------------
1 cell+ 2 = verif
2 cells 2 = verif
5 cells 5 = verif
1 aligned 1 = verif
5 aligned 5 = verif
123 aligned 123 = verif

\ ---------------------------------------------------------------------------
\ B9 - allocation : 2 cellules = 2 unites d'adresse
\ ---------------------------------------------------------------------------
here 2 cells allot here swap - 2 = verif
here 1 cells allot here swap - 1 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 23
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour23.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
