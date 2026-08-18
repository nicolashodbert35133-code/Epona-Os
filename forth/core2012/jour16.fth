\ ============================================================================
\ forth/core2012/jour16.fth - Correction de STATE
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 16
\ Cellule reservee state_addr = MAX_MEM-2, source de verite du tokenizer.
\ state pousse state_addr ; ] et les mots : ; [ ] du tokenizer lisent/
\ ecrivent la cellule ; champ Rust self.state supprime.
\ Section B5 : lecture (state @), ecriture dans une definition
\ (: st-set 5 state ! ... ;), bascule reelle 1 state ! [ ... ] puis retour.
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
: st-set 5 state ! state @ 5 = verif 0 state ! ;
st-set
state @ 0 = verif

\ ---------------------------------------------------------------------------
\ B5 - Bascule reelle : 1 state ! force le tokenizer en mode compilation
\ ---------------------------------------------------------------------------
\ Preuve : le token '[' est traite par le MODE COMPILATION (il ramene state
\ a 0, interpreter.rs). En mode immediat, '[' serait "Mot inconnu" : si on
\ passe cette ligne sans erreur, la bascule reelle a fonctionne. On verifie
\ ensuite que l'etat est bien revenu a 0 (mode immediat).
1 state !
[
state @ 0 = verif

\ ']' (mode immediat) bascule en compilation, '[' (mode compilation) revient
] [
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
