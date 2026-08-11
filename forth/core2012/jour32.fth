\ ============================================================================
\ forth/core2012/jour32.fth - DOES>
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 32
\ (inclus dans le Jour 31). Flux does> analyse et corrige : body insere
\ AVANT l'Exit final ([Push(data_addr), ...body, Exit]), data_addr pousse
\ sur la pile. Bloc does_offset du ; redondant (does_ops deja extrait par
\ rposition(DoesMarker)) -> supprime, sans demi-correction.
\ Teste par B17 : my-const / plus-data : le body est bien atteint et
\ consomme data_addr.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour32.fth   (dans qemu_img)
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
\ B17 - pattern create , does> @ (my-const)
\ ---------------------------------------------------------------------------
create my-const 100 , does> @ ;
my-const 100 = verif

\ ---------------------------------------------------------------------------
\ B17 - body consomme data_addr (plus-data : @ 10 +)
\ ---------------------------------------------------------------------------
create plus-data 5 , does> @ 10 + ;
plus-data 15 = verif

\ ---------------------------------------------------------------------------
\ B17 - two defining words, adresses distinctes
\ ---------------------------------------------------------------------------
create plus-1 1 , does> @ 1 + ;
create plus-2 2 , does> @ 2 + ;
plus-1 2 = verif
plus-2 4 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 32
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour32.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
