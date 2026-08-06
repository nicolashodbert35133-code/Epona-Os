\ ============================================================================
\ TESTS/refill.fth - Tests interactifs REFILL (Semaine 2, Jour 12)
\ ----------------------------------------------------------------------------
\ REFILL ( -- flag )
\   -1 : ligne lue avec succes (MEME SI VIDE)  <- correction Jour 12
\    0 : annulation (Escape) ou aucune entree disponible (preemption,
\        emergency_break).
\ Ces tests exigent le clavier : exec TESTS/refill.fth puis suivre les
\ instructions. Les echecs sont comptes dans NB-FAILS (auto) ; chaque test
\ imprime la valeur reelle du flag.
\ ============================================================================
variable NB-FAILS
0 NB-FAILS !

\ verif : verifie que le flag vaut true (-1). Affiche la valeur reelle.
: verif ( flag -- )
  dup .
  true = if else
    1 NB-FAILS +!
    ."  <- ECHEC (attendu -1)" cr
  then ;

cr
." ==========================" cr
." Tests interactifs REFILL" cr
." Lancement : appuyez sur les touches demandees." cr
." ==========================" cr

\ --- TEST 1 : entree NON VIDE ---
." TEST 1 : tapez  abc  puis Entree. Attendu flag -1." cr
refill verif
cr

\ --- TEST 2 : LIGNE VIDE (LA correction du jour 12) ---
." TEST 2 : appuyez sur ENTREE DIRECTEMENT (ligne vide)." cr
." Attendu flag -1 (avant Jour 12 : 0 = EOF a tort)." cr
refill verif
cr

\ --- TEST 3 : backspace ---
." TEST 3 : tapez  abx  puis Backspace puis Entree." cr
." (le x doit disparaitre) Attendu flag -1." cr
refill verif
cr

\ --- TEST 4 : Escape (annulation) ---
." TEST 4 : appuyez sur ECHAP (ESC). Attendu flag 0." cr
refill 0= verif
cr

\ --- TEST 5 : preemption (documente, non declenchable a la main) ---
." TEST 5 : preemption - NON testable a la main de facon fiable." cr
." Le code pousse 0 quand PREEMPT_REQUESTED ou emergency_break." cr
." (comportement inchange depuis avant le Jour 12, pas une regression)." cr
cr

." ==========================" cr
." NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." REFILL : tous les tests interactifs OK" cr
else
  ." REFILL : echecs - revoir la procedure (voir commentaires)" cr
then
." ==========================" cr
