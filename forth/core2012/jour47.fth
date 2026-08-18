\ ============================================================================
\ forth/core2012/jour47.fth - ABORT
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 47
\ abort(419) ( i*x -- ) Core. Contrat d'etat documente : pile de donnees
\ videe, piles de retour/boucle/catch videes, STATE=0, etat compilateur
\ efface (compiling_ops/name/stack, recurse_fixups, does_offset,
\ compiling_locals), reste de la source courante non execute (boucle
\ compile sort via abort_pending), aucun message ni erreur (difference
\ avec ABORT"), >IN/BASE/HERE inchanges. En contexte evaluate/included,
\ la source externe reprend. depth(436) ajoute (Extension) pour asserter
\ la pile videe. Section B31 : 4 cas abort via evaluate + test depth.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour47.fth   (dans qemu_img)
\
\ PERIMETRE : CORE / CORE EXT + extension Epona marquee (depth).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !
variable abort-flag

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ ---------------------------------------------------------------------------
\ B31 - (a) le code qui suit "abort" ne doit PAS s'executer
\ ---------------------------------------------------------------------------
0 abort-flag !
s" abort 1 abort-flag !" evaluate
abort-flag @ 0 = verif

\ ---------------------------------------------------------------------------
\ B31 - (b) la pile de donnees est VIDE apres abort (depth = 0)
\ ---------------------------------------------------------------------------
s" 1 2 3 abort" evaluate
depth 0 = verif

\ ---------------------------------------------------------------------------
\ B31 - (c) silencieux : le code apres abort dans la source est ignore
\        (7 8 + ne s'execute pas, la pile reste vide)
\ ---------------------------------------------------------------------------
s" 1 2 3 abort 7 8 +" evaluate
depth 0 = verif

\ ---------------------------------------------------------------------------
\ B31 - (d) STATE = interpretation apres abort
\ ---------------------------------------------------------------------------
s" abort" evaluate
state @ 0 = verif

\ ---------------------------------------------------------------------------
\ B31 - depth (extension Epona)
\ ---------------------------------------------------------------------------
1 2 3 depth
3 = verif
drop drop drop

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 47
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour47.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
