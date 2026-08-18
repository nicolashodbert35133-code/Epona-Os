\ ============================================================================
\ forth/core2012/jour41.fth - Sortie numerique
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 41
\ ud.(402)/d.(403) ajoutes + helper u128 pno_convert (zone PNO, BASE
\ courante, chiffres majuscules). d. gere le signe via hi<0 -> "-" +
\ magnitude (wrapping_neg). Section B26 : u64 max decimal/hex, base 2,
\ negatif profond, positif 2^64, consommation du double (sentinelle).
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour41.fth   (dans qemu_img)
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
\ B26 - ud. : u64 max (lo=-1) affiche 18446744073709551615, consomme 2 cellules
\ ---------------------------------------------------------------------------
1 -1 0 ud.
1 = verif

\ ---------------------------------------------------------------------------
\ B26 - d. : negatif profond (2 -1 = -2^64 + 2), consomme 2 cellules
\ ---------------------------------------------------------------------------
-2 2 -1 d.
-2 = verif

\ ---------------------------------------------------------------------------
\ B26 - base 2
\ ---------------------------------------------------------------------------
2 base !
1 0 ud.
decimal

\ ---------------------------------------------------------------------------
\ B26 - d. positif 2^64 (0 1), consomme 2 cellules
\ ---------------------------------------------------------------------------
5 0 1 d.
5 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 41
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour41.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
