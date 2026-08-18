\ ============================================================================
\ forth/core2012/jour10.fth - RSHIFT
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 10
\ RSHIFT logique : ((v as u64) >> n) as i64, compte mod 64 (SHR x86).
\ Section B2 : positifs (16 2 = 4, 1 4 = 0, 1 0 = 1), negatifs (-16 2 =
\ 0x3FFFFFFFFFFFFFFC, -1 63 = 1, -2 1 = MAX, -16 4 = 0x0FFFFFFFFFFFFFFF),
\ decalage nul (-16 0 = -16, 123 0 = 123), >= 64 bits (-1 64 = -1,
\ 1 65 = 0 -- mod 64). lshift logique deja conforme.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour10.fth   (dans qemu_img)
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
\ POSITIFS
\ ---------------------------------------------------------------------------
16 2 rshift 4 = verif
1 4 rshift 0 = verif
1 0 rshift 1 = verif
123 0 rshift 123 = verif

\ ---------------------------------------------------------------------------
\ NEGATIFS (decalage LOGIQUE : bits a 0 injectes a gauche)
\ ---------------------------------------------------------------------------
-16 2 rshift 4611686018427387900 = verif
-1 63 rshift 1 = verif
-2 1 rshift 9223372036854775807 = verif
-16 4 rshift 1152921504606846975 = verif

\ ---------------------------------------------------------------------------
\ DECALAGE NUL
\ ---------------------------------------------------------------------------
-16 0 rshift -16 = verif
123 0 rshift 123 = verif

\ ---------------------------------------------------------------------------
\ >= 64 BITS (compte mod 64)
\ ---------------------------------------------------------------------------
-1 64 rshift -1 = verif
1 65 rshift 0 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 10
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour10.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
