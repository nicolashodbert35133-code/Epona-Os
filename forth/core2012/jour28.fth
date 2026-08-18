\ ============================================================================
\ forth/core2012/jour28.fth - Revue semaine 4 (ALLOC repare)
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 28
\ Revue S4 : migration maintenue. MAX_MEM porte de 4096 a 131072.
\ alloc (95) repare : reservait memory.len() -> echec systematique
\ (EDITEUR 10000 alloc -> -1) ; desormais reserve size cellules depuis
\ here via checked_add, message « Erreur: alloc — memoire insuffisante »,
\ here inchange si echec. Section B14 : tests alloc.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour28.fth   (dans qemu_img)
\
\ PERIMETRE : CORE / CORE EXT + extension Epona marquee (alloc).
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
\ B14 - ALLOC d'une taille raisonnable -> adresse valide (plus de -1)
\ ---------------------------------------------------------------------------
10000 alloc
dup 0 >= verif
dup here <= verif
drop

\ ---------------------------------------------------------------------------
\ B14 - ALLOC depassant la memoire -> -1, here inchange
\ ---------------------------------------------------------------------------
here 200000 alloc drop here = verif
200000 alloc -1 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 28
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour28.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
