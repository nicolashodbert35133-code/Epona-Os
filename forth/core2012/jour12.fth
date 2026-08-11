\ ============================================================================
\ forth/core2012/jour12.fth - REFILL
\
\ Base : PLANNING_CODAGE_FORTH_12_SEMAINES.md - Jour 12
\ REFILL corrige : distinguer ligne vide VALIDE et absence d'entree.
\ Code (interpreter.rs idx 331) : boolen `cancelled` -- Escape -> 0
\ (annulation) ; sinon (ligne lue, meme vide) -> source_buffer = line,
\ >IN = 0, flag -1 (succes). Preemption et emergency_break inchanges
\ (0 = aucune entree disponible). Tests clavier interactifs QEMU.
\
\ Conventions Epona :
\   - chaque test imprime sa VALEUR REELLE via '.'
\   - '\ -1' = test OK,  '\ 0' = echec
\   - '... = verif' compte les echecs dans NB-FAILS (auto)
\   - lancement : exec forth/core2012/jour12.fth   (dans qemu_img)
\   - ATTENTION : test INTERACTIF, necessite le clavier QEMU.
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

cr
." ==========================" cr
." Tests interactifs REFILL - Jour 12" cr
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

\ ---------------------------------------------------------------------------
\ RESUME JOURNEE 12
\ ---------------------------------------------------------------------------
cr
." ==========================" cr
." jour12.fth - NB-FAILS = " NB-FAILS @ . cr
NB-FAILS @ 0= if
  ." REFILL : tous les tests interactifs OK" cr
else
  ." REFILL : echecs - revoir la procedure (voir commentaires)" cr
then
." ==========================" cr
