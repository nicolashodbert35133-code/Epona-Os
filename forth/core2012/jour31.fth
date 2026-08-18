\ ============================================================================
\ forth/core2012/jour31.fth - CREATE
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 31
\ Option A standard : CREATE ne reserve plus (data_addr = here, identique
\ a buffer:) ; la memoire est reservee par , ou ALLOT apres CREATE.
\ Section B17 : create ne reserve pas, create N allot, , / @,
\ pattern create , does> @ (voir Jour 32).
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour31.fth   (dans qemu_img)
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
\ B17 - CREATE ne reserve PAS (data_addr = here au moment du create)
\ ---------------------------------------------------------------------------
here create c31
c31 here = verif

\ ---------------------------------------------------------------------------
\ B17 - CREATE + ALLOT : memoire reservee ensuite
\ ---------------------------------------------------------------------------
create c31a 2 allot
123 c31a !
c31a @ 123 = verif
456 c31a 1 + !
c31a 1 + @ 456 = verif

\ ---------------------------------------------------------------------------
\ B17 - CREATE + , : donnee stockee
\ ---------------------------------------------------------------------------
create c31e 7 ,
c31e @ 7 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 31
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour31.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
