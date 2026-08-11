\ ============================================================================
\ forth/core2012/jour16.fth - Correction de STATE
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 16
\ Cellule reservee state_addr = MAX_MEM-2, source de verite du tokenizer.
\ state pousse state_addr ; ] et les mots : ; [ ] du tokenizer lisent/
\ ecrivent la cellule ; champ Rust self.state supprime.
\ Section B5 : lecture (state @), ecriture dans une definition
\ (: st-set state 5 ! ... ;), bascule reelle 1 state ! [ ... ] puis retour.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour16.fth   (dans qemu_img)
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
\ B5 - STATE est une ADRESSE modifiable
\ ---------------------------------------------------------------------------
state @ 0 = verif
: st-set state 5 ! ;
st-set
state @ 5 = verif
0 state ! state @ 0 = verif

\ ---------------------------------------------------------------------------
\ B5 - Bascule reelle 1 state ! [ ... ] puis retour
\ ---------------------------------------------------------------------------
1 state ! [ state @ 1 = verif 0 state ! ]
state @ 0 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 16
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour16.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
