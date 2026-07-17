\ TEST-LOOP.FTH — Tests pour les boucles JIT DO/LOOP
\ Version: 1.00
\ Date: 2026-07-17
\
\ Ce fichier teste les boucles compilées en JIT :
\   DO, ?DO, LOOP, +LOOP, LEAVE, i, j
\
\ Usage :
\   include TEST-LOOP.FTH
\   test-loops

variable tests-passed
variable tests-failed

: test-assert ( flag -- )
  if 1 tests-passed +!
  else 1 tests-failed +! then
;

: test-separator ( -- )
  cr ." ----------------------------------------" cr
;

\ ============================================================================
\ TESTS DO/LOOP de base
\ ============================================================================

: test-do-loop-sum ( -- )
  test-separator
  ." Test: DO/LOOP somme 0+1+2+...+9" cr
  0 0 10 do i + loop
  45 = test-assert
  \ Attendu : 0+1+2+3+4+5+6+7+8+9 = 45
  ."   Resultat attendu: 45, obtenu: " . cr
;

: test-do-loop-count ( -- )
  test-separator
  ." Test: DO/LOOP compteur" cr
  0 0 5 do 1+ loop
  5 = test-assert
  ."   Resultat attendu: 5, obtenu: " . cr
;

: test-do-loop-down ( -- )
  test-separator
  ." Test: DO/LOOP descendant" cr
  0 10 0 do i + loop
  45 = test-assert
  \ 9+8+7+6+5+4+3+2+1+0 = 45
  ."   Resultat attendu: 45, obtenu: " . cr
;

\ ============================================================================
\ TESTS ?DO (boucle conditionnelle)
\ ============================================================================

: test-qdo-skip ( -- )
  test-separator
  ." Test: ?DO skip quand limit = start" cr
  0 5 5 ?do 1+ loop
  0 = test-assert
  \ La boucle ne s'exécute pas (5 = 5)
  ."   Resultat attendu: 0, obtenu: " . cr
;

: test-qdo-execute ( -- )
  test-separator
  ." Test: ?DO execute quand limit != start" cr
  0 5 3 ?do 1+ loop
  2 = test-assert
  \ La boucle s'exécute 2 fois (3, 4)
  ."   Resultat attendu: 2, obtenu: " . cr
;

\ ============================================================================
\ TESTS +LOOP (increment variable)
\ ============================================================================

: test-plusloop-positive ( -- )
  test-separator
  ." Test: +LOOP avec increment positif" cr
  0 0 10 2 do i + loop
  20 = test-assert
  \ 0+2+4+6+8 = 20
  ."   Resultat attendu: 20, obtenu: " . cr
;

: test-plusloop-negative ( -- )
  test-separator
  ." Test: +LOOP avec increment negatif" cr
  0 10 0 do -1 +loop
  10 = test-assert
  \ Boucle 10 fois avec -1
  ."   Resultat attendu: 10, obtenu: " . cr
;

\ ============================================================================
\ TESTS LEAVE (sortie anticipee)
\ ============================================================================

: test-leave ( -- )
  test-separator
  ." Test: LEAVE sort de la boucle" cr
  0 0 100 do i + 5 i = if leave then loop
  10 = test-assert
  \ 0+1+2+3+4 = 10, puis leave
  ."   Resultat attendu: 10, obtenu: " . cr
;

\ ============================================================================
\ TESTS i et j (index imbriques)
\ ============================================================================

: test-i-index ( -- )
  test-separator
  ." Test: i retourne l'index courant" cr
  0 3 0 do i loop
  2 = test-assert
  \ Dernier index = 2
  ."   Resultat attendu: 2, obtenu: " . cr
;

: test-j-index ( -- )
  test-separator
  ." Test: j retourne l'index externe" cr
  0
  3 0 do
    2 0 do
      j +
    loop
  loop
  9 = test-assert
  \ (0*2 + 0+1) + (1*2 + 0+1) + (2*2 + 0+1) = 1 + 3 + 5 = 9
  ."   Resultat attendu: 9, obtenu: " . cr
;

\ ============================================================================
\ TESTS BOUCLES IMBRIQUEES
\ ============================================================================

: test-nested-loops ( -- )
  test-separator
  ." Test: Boucles imbriquees" cr
  0
  3 0 do
    4 0 do
      i j * +
    loop
  loop
  36 = test-assert
  \ Somme de i*j pour i=0..2, j=0..3
  \ (0*0+0*1+0*2+0*3) + (1*0+1*1+1*2+1*3) + (2*0+2*1+2*2+2*3) = 0+6+12 = 18
  \ Attendu : 18
  ."   Resultat attendu: 18, obtenu: " . cr
;

\ ============================================================================
\ TESTS DEBOURSAGE (nested DO/LOOP avec i et j)
\ ============================================================================

: test-deobfuscation ( -- )
  test-separator
  ." Test: Deobfuscation avec i et j" cr
  0
  5 0 do
    3 0 do
      j 1+ i 1+ * +
    loop
  loop
  90 = test-assert
  \ Chaque iteration interne : (j+1) * (i+1)
  \ j=0: 1*1+1*2+1*3 = 6
  \ j=1: 2*1+2*2+2*3 = 12
  \ j=2: 3*1+3*2+3*3 = 18
  \ j=3: 4*1+4*2+4*3 = 24
  \ j=4: 5*1+5*2+5*3 = 30
  \ Total = 6+12+18+24+30 = 90
  ."   Resultat attendu: 90, obtenu: " . cr
;

\ ============================================================================
\ TITRE
\ ============================================================================

: test-loops ( -- )
  cr
  cr ." ========================================"
  cr ."  Tests JIT — Boucles DO/LOOP"
  cr ." ========================================"
  cr

  0 tests-failed !
  0 tests-passed !

  \ Exécuter tous les tests
  test-do-loop-sum
  test-do-loop-count
  test-do-loop-down
  test-qdo-skip
  test-qdo-execute
  test-plusloop-positive
  test-plusloop-negative
  test-leave
  test-i-index
  test-j-index
  test-nested-loops
  test-deobfuscation

  cr
  cr ." ========================================"
  cr ." Resultats :"
  tests-passed @ . ." passes"
  tests-failed @ ?dup if
    ." , " . ." ECHECS"
  else
    ." , 0 echec"
  then
  cr ." ========================================"
  cr
;
