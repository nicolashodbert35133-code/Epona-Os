\ ============================================================================
\ forth/core2012/jour43.fth - KEY
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 43
\ key(404) Core bloquant + key?(405) Extension non bloquant et sans
\ consommation. Factorisation : helper blocking_key() (attend un char de
\ key_queue bornee a 64, pompe step_callback, retourne 0 si preemption
\ PIT / emergency_break) ; touche(17) refactorise dessus. key_queue
\ alimentee par polling PS/2 + xHCI + bureau.
\ Section B27 : etats non bloquants ; lecture reelle manuelle QEMU.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour43.fth   (dans qemu_img)
\   - ATTENTION : le dernier test est INTERACTIF (clavier QEMU).
\
\ PERIMETRE : CORE / CORE EXT + extension Epona marquee (key?).
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
\ B27 - key? : non bloquant, etats de base
\ ---------------------------------------------------------------------------
key? 0 = verif
key? 0 = verif

\ ---------------------------------------------------------------------------
\ B27 - lecture via injection (automatisé)
\ ---------------------------------------------------------------------------
65 touche:inject
key
65 = verif

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 43
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour43.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." TOUTES LES CIBLES ATTEINTES" cr
else
  ." CORRECTIONS RESTANTES" cr
then
." ==========================" cr
