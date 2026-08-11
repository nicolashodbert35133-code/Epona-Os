\ ============================================================================
\ forth/core2012/jour48.fth - QUIT
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 48
\ quit(437) ( -- ) Core. Effet : pile de retour videe (rstack/loop_rstack/
\ handler_stack), STATE=0, etat compilateur efface (meme nettoyage que
\ abort), source courante arretee via abort_pending (retour au prompt),
\ PILE DE DONNEES CONSERVEE (difference avec ABORT), silencieux. Pas de
\ simple return : la restauration d'etat est complete et le flag est
\ consomme par les checks de compile/execute_ops_limited.
\ Section B32 : 3 cas via evaluate : code suivant ignore, depth=3 pile
\ conservee, STATE=0.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour48.fth   (dans qemu_img)
\
\ PERIMETRE : CORE / CORE EXT + extension Epona marquee (depth).
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !
variable quit-flag

: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

\ ---------------------------------------------------------------------------
\ B32 - le code qui suit "quit" ne doit PAS s'executer
\ ---------------------------------------------------------------------------
0 quit-flag !
s" quit 1 quit-flag !" evaluate
quit-flag @ 0 = verif

\ ---------------------------------------------------------------------------
\ B32 - la pile de DONNEES est CONSERVEE (depth = 3)
\ ---------------------------------------------------------------------------
1 2 3 s" quit" evaluate
depth 3 = verif
drop drop drop

\ ---------------------------------------------------------------------------
\ B32 - STATE = interpretation apres quit
\ ---------------------------------------------------------------------------
s" quit" evaluate
state @ 0 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 48
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour48.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
