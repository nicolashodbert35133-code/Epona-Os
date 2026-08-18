\ ============================================================================
\ forth/core2012/jour11.fth - SEARCH
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 11
\ SEARCH corrige : sous-chaine vide (len2 == 0) toujours trouvee
\ (addr3 = addr1, len3 = len1, flag -1). Forme de pile
\ ( addr1 len1 addr2 len2 -- addr3 len3 flag ), flag -1/0.
\ Section B3 : trouvee en position 3 (addr3 = addr1+3), debut, fin,
\ multi-occurrences, non trouvee (len3 = len1, addr3 = addr1),
\ sous-chaine vide 0 0 (la correction), len2 > len1.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour11.fth   (dans qemu_img)
\
\ PERIMETRE : uniquement des mots Forth 2012 (CORE / CORE EXT).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !
variable S1

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ ---------------------------------------------------------------------------
\ B3 - SEARCH
\ ---------------------------------------------------------------------------
\ Trouvee en position 3 (addr3 = addr1 + 3)
s" ABCDEFGHIJ" over S1 ! s" DEFG" search
-1 = verif
drop S1 @ 3 + = verif

\ Trouvee au debut (addr3 = addr1)
s" ABCDEFGHIJ" over S1 ! s" ABCD" search
-1 = verif
drop S1 @ = verif

\ Trouvee en fin (addr3 = addr1 + 7)
s" ABCDEFGHIJ" over S1 ! s" HIJ" search
-1 = verif
drop S1 @ 7 + = verif

\ Multi-occurrences (premiere occurrence)
s" ABAB" over S1 ! s" AB" search
-1 = verif
drop S1 @ = verif

\ Non trouvee : flag 0, len3 = len1, addr3 = addr1
s" ABCDEFGHIJ" over S1 ! s" XYZ" search
0 = verif
drop S1 @ = verif

\ Sous-chaine vide 0 0 : TOUJOURS trouvee (la correction du Jour 11)
s" ABC" over S1 ! s" " search
-1 = verif
drop S1 @ = verif

\ len2 > len1 : non trouvee (flag 0)
s" ABC" s" ABCD" search
0 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 11
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour11.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
