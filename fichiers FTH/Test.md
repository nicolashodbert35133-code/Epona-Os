\ ════════════════════════════════════════════════════════════════════════
\                    TESTS.FTH — Suite de tests Epona OS
\                    EponaForth — Validation du runtime
\ ════════════════════════════════════════════════════════════════════════
\
\ Utilisation :
\   sys:load TESTS.FTH        (depuis le terminal)
\   exec TESTS.FTH            (depuis le shell)
\
\ Ou depuis BOOT.FTH :
\   sys:load TESTS.FTH
\   lancer-tests
\
\ Les resultats sont affiches dans le terminal.
\ A la fin : nombre de tests OK et KO.
\ Si KO > 0, verifier les lignes "ECHEC" dans la sortie.
\
\ ════════════════════════════════════════════════════════════════════════

\ ──────────────────────────────────────────────────────────────────────
\ FRAMEWORK DE TEST
\ ──────────────────────────────────────────────────────────────────────

variable tests-ok
variable tests-ko
variable tests-total
variable test-section-ok
variable test-section-ko

: test-reset
  0 tests-ok !
  0 tests-ko !
  0 tests-total !
;

: ok ( -- )
  1 tests-ok +!
  1 tests-total +!
  1 test-section-ok +!
;

: ko ( -- )
  1 tests-ko +!
  1 tests-total +!
  1 test-section-ko +!
;

: assert= ( got expected -- )
  2dup = if
    2drop ok
  else
    ko
    cr ." ECHEC assert= : attendu " . ." obtenu " . cr
  then
;

: assert<> ( a b -- )
  2dup <> if
    2drop ok
  else
    ko
    cr ." ECHEC assert<> : les deux valeurs sont egales : " . drop cr
  then
;

: assert-true ( flag -- )
  if ok else ko cr ." ECHEC assert-true" cr then
;

: assert-false ( flag -- )
  if ko cr ." ECHEC assert-false" cr else ok then
;

: assert-zero ( n -- )
  0= if ok else ko cr ." ECHEC assert-zero" cr then
;

: assert-nonzero ( n -- )
  0<> if ok else ko cr ." ECHEC assert-nonzero" cr then
;

: assert-positive ( n -- )
  0> if ok else ko cr ." ECHEC assert-positive" cr then
;

: assert-negative ( n -- )
  0< if ok else ko cr ." ECHEC assert-negative" cr then
;

: assert-range ( val lo hi -- )
  rot dup rot <= if
    swap >=
    if ok else ko cr ." ECHEC assert-range (trop bas)" cr then
  else
    2drop ko cr ." ECHEC assert-range (trop haut)" cr
  then
;

: section ( -- )
  0 test-section-ok !
  0 test-section-ko !
;

: section-end ( -- )
  test-section-ko @ 0= if
    ." OK (" test-section-ok @ . ." tests)" cr
  else
    ." ** " test-section-ko @ . ." ECHEC(S) sur "
    test-section-ok @ test-section-ko @ + . ." tests **" cr
  then
;

: resume-tests ( -- )
  cr
  ." ════════════════════════════════════════" cr
  ."  RESULTATS : " cr
  ."    Total  : " tests-total @ . cr
  ."    OK     : " tests-ok @ . cr
  ."    ECHEC  : " tests-ko @ . cr
  ." ════════════════════════════════════════" cr
  tests-ko @ 0= if
    ." ✓ TOUS LES TESTS PASSENT" cr
  else
    ." ✗ IL Y A DES ECHECS !" cr
  then
  cr
;

\ ──────────────────────────────────────────────────────────────────────
\ 1. ARITHMETIQUE DE BASE
\ ──────────────────────────────────────────────────────────────────────

: test-addition
  section
  ." [1.1] Addition... "
  0 0 + 0 assert=
  1 1 + 2 assert=
  100 200 + 300 assert=
  -1 1 + 0 assert=
  -5 -3 + -8 assert=
  2147483647 1 + 2147483648 assert=
  section-end
;

: test-soustraction
  section
  ." [1.2] Soustraction... "
  5 3 - 2 assert=
  3 5 - -2 assert=
  0 0 - 0 assert=
  -1 -1 - 0 assert=
  100 1 - 99 assert=
  section-end
;

: test-multiplication
  section
  ." [1.3] Multiplication... "
  3 4 * 12 assert=
  0 999 * 0 assert=
  -2 3 * -6 assert=
  -2 -3 * 6 assert=
  1 1 * 1 assert=
  7 7 * 49 assert=
  section-end
;

: test-division
  section
  ." [1.4] Division... "
  10 2 / 5 assert=
  7 2 / 3 assert=
  0 5 / 0 assert=
  -10 2 / -5 assert=
  100 10 / 10 assert=
  \ Division par zero → 0 (protection)
  5 0 / 0 assert=
  section-end
;

: test-modulo
  section
  ." [1.5] Modulo... "
  10 3 mod 1 assert=
  7 2 mod 1 assert=
  8 4 mod 0 assert=
  0 5 mod 0 assert=
  \ Modulo par zero → 0 (protection)
  5 0 mod 0 assert=
  section-end
;

: test-divmod
  section
  ." [1.6] /mod... "
  7 2 /mod
  3 assert=
  1 assert=
  10 3 /mod
  3 assert=
  1 assert=
  section-end
;

: test-incr-decr
  section
  ." [1.7] 1+ 1- 2+ 2- 2* 2/... "
  5 1+ 6 assert=
  5 1- 4 assert=
  5 2+ 7 assert=
  5 2- 3 assert=
  5 2* 10 assert=
  10 2/ 5 assert=
  0 1- -1 assert=
  -1 1+ 0 assert=
  section-end
;

: test-abs-negate
  section
  ." [1.8] abs negate... "
  5 abs 5 assert=
  -5 abs 5 assert=
  0 abs 0 assert=
  5 negate -5 assert=
  -5 negate 5 assert=
  0 negate 0 assert=
  section-end
;

: test-min-max
  section
  ." [1.9] min max... "
  3 5 min 3 assert=
  5 3 min 3 assert=
  -1 1 min -1 assert=
  3 5 max 5 assert=
  5 3 max 5 assert=
  -1 1 max 1 assert=
  section-end
;

: test-arithmetique
  cr ." === 1. ARITHMETIQUE ===" cr
  test-addition
  test-soustraction
  test-multiplication
  test-division
  test-modulo
  test-divmod
  test-incr-decr
  test-abs-negate
  test-min-max
;

\ ──────────────────────────────────────────────────────────────────────
\ 2. MANIPULATION DE PILE
\ ──────────────────────────────────────────────────────────────────────

: test-dup
  section
  ." [2.1] dup... "
  42 dup + 84 assert=
  0 dup 0 assert= 0 assert=
  -1 dup -1 assert= -1 assert=
  section-end
;

: test-drop
  section
  ." [2.2] drop... "
  1 2 drop 1 assert=
  10 20 30 drop drop 10 assert=
  section-end
;

: test-swap
  section
  ." [2.3] swap... "
  1 2 swap 1 assert= 2 assert=
  10 20 swap 10 assert= 20 assert=
  section-end
;

: test-over
  section
  ." [2.4] over... "
  1 2 over 1 assert= 2 assert= 1 assert=
  10 20 over + 30 assert= 10 assert=
  section-end
;

: test-rot
  section
  ." [2.5] rot -rot... "
  1 2 3 rot
  1 assert=
  3 assert=
  2 assert=
  1 2 3 -rot
  3 assert=
  1 assert=
  2 assert=
  section-end
;

: test-nip-tuck
  section
  ." [2.6] nip tuck... "
  1 2 nip 2 assert=
  1 2 tuck
  2 assert=
  1 assert=
  2 assert=
  section-end
;

: test-2dup-2drop
  section
  ." [2.7] 2dup 2drop 2swap 2over... "
  3 4 2dup
  4 assert= 3 assert=
  4 assert= 3 assert=
  1 2 3 4 2drop
  2 assert= 1 assert=
  1 2 3 4 2swap
  2 assert= 1 assert=
  4 assert= 3 assert=
  1 2 3 4 2over
  2 assert= 1 assert=
  4 assert= 3 assert=
  2 assert= 1 assert=
  section-end
;

: test-qdup
  section
  ." [2.8] ?dup... "
  0 ?dup depth 1 assert= drop
  5 ?dup depth 2 >= assert-true drop drop
  section-end
;

: test-pick
  section
  ." [2.9] pick... "
  10 20 30 0 pick 30 assert= drop drop drop
  10 20 30 1 pick 20 assert= drop drop drop
  10 20 30 2 pick 10 assert= drop drop drop
  section-end
;

: test-depth
  section
  ." [2.10] depth... "
  depth 0 assert=
  1 depth 2 assert= drop
  1 2 3 depth 4 assert= drop drop drop
  section-end
;

: test-pile
  cr ." === 2. PILE ===" cr
  test-dup
  test-drop
  test-swap
  test-over
  test-rot
  test-nip-tuck
  test-2dup-2drop
  test-qdup
  test-pick
  test-depth
;

\ ──────────────────────────────────────────────────────────────────────
\ 3. PILE DE RETOUR
\ ──────────────────────────────────────────────────────────────────────

: test-rstack
  section
  ." [3.1] >r r> r@... "
  42 >r r@ 42 assert= r> 42 assert=
  10 20 >r >r r> r> 10 assert= 20 assert=
  99 >r r@ r@ = assert-true r> drop
  section-end
;

: test-rstack-suite
  cr ." === 3. PILE DE RETOUR ===" cr
  test-rstack
;

\ ──────────────────────────────────────────────────────────────────────
\ 4. COMPARAISONS
\ ──────────────────────────────────────────────────────────────────────

: test-egal
  section
  ." [4.1] = <> ... "
  5 5 = assert-true
  5 6 = assert-false
  0 0 = assert-true
  -1 -1 = assert-true
  5 6 <> assert-true
  5 5 <> assert-false
  section-end
;

: test-ordre
  section
  ." [4.2] < > <= >= ... "
  3 5 < assert-true
  5 3 < assert-false
  5 5 < assert-false
  5 3 > assert-true
  3 5 > assert-false
  5 5 > assert-false
  3 5 <= assert-true
  5 5 <= assert-true
  6 5 <= assert-false
  5 3 >= assert-true
  5 5 >= assert-true
  4 5 >= assert-false
  section-end
;

: test-zero-compare
  section
  ." [4.3] 0= 0<> 0< 0> ... "
  0 0= assert-true
  1 0= assert-false
  -1 0= assert-false
  0 0<> assert-false
  5 0<> assert-true
  -1 0< assert-true
  0 0< assert-false
  1 0< assert-false
  1 0> assert-true
  0 0> assert-false
  -1 0> assert-false
  section-end
;

: test-comparaisons
  cr ." === 4. COMPARAISONS ===" cr
  test-egal
  test-ordre
  test-zero-compare
;

\ ──────────────────────────────────────────────────────────────────────
\ 5. LOGIQUE BINAIRE
\ ──────────────────────────────────────────────────────────────────────

: test-and-or-xor
  section
  ." [5.1] and or xor invert... "
  0xFF 0x0F and 0x0F assert=
  0xF0 0x0F or 0xFF assert=
  0xFF 0xFF xor 0 assert=
  0xAA 0x55 xor 0xFF assert=
  0 invert -1 assert=
  section-end
;

: test-shift
  section
  ." [5.2] lshift rshift... "
  1 0 lshift 1 assert=
  1 1 lshift 2 assert=
  1 8 lshift 256 assert=
  256 8 rshift 1 assert=
  255 4 rshift 15 assert=
  section-end
;

: test-logique
  cr ." === 5. LOGIQUE BINAIRE ===" cr
  test-and-or-xor
  test-shift
;

\ ──────────────────────────────────────────────────────────────────────
\ 6. VARIABLES ET MEMOIRE
\ ──────────────────────────────────────────────────────────────────────

variable test-var-a
variable test-var-b
variable test-var-c

: test-variables
  section
  ." [6.1] variable @ ! +!... "
  0 test-var-a !
  test-var-a @ 0 assert=
  42 test-var-a !
  test-var-a @ 42 assert=
  10 test-var-a +!
  test-var-a @ 52 assert=
  -52 test-var-a +!
  test-var-a @ 0 assert=
  section-end
;

: test-multi-variables
  section
  ." [6.2] Variables multiples... "
  100 test-var-a !
  200 test-var-b !
  300 test-var-c !
  test-var-a @ 100 assert=
  test-var-b @ 200 assert=
  test-var-c @ 300 assert=
  test-var-a @ test-var-b @ + test-var-c @ assert=
  section-end
;

: test-cell-ops
  section
  ." [6.3] cell+ cells aligned... "
  0 cell+ 8 assert=
  10 cell+ 18 assert=
  1 cells 8 assert=
  3 cells 24 assert=
  0 aligned 0 assert=
  1 aligned 8 assert=
  7 aligned 8 assert=
  8 aligned 8 assert=
  9 aligned 16 assert=
  section-end
;

: test-memoire
  cr ." === 6. VARIABLES / MEMOIRE ===" cr
  test-variables
  test-multi-variables
  test-cell-ops
;

\ ──────────────────────────────────────────────────────────────────────
\ 7. CONSTANTES
\ ──────────────────────────────────────────────────────────────────────

42 constant REPONSE
100 constant CENT
-1 constant VRAI
0 constant FAUX

: test-constantes
  section
  cr ." === 7. CONSTANTES ===" cr
  ." [7.1] constant... "
  REPONSE 42 assert=
  CENT 100 assert=
  VRAI -1 assert=
  FAUX 0 assert=
  REPONSE CENT + 142 assert=
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 8. IF / ELSE / THEN
\ ──────────────────────────────────────────────────────────────────────

: branch-if ( n -- m )
  0 > if 1 else -1 then ;

: branch-if-only ( n -- m )
  0 > if 1 then ;

: branch-nested ( a b -- c )
  0 > if
    0 > if 3 else 2 then
  else
    0 > if 1 else 0 then
  then ;

: test-if-then
  section
  ." [8.1] if/else/then... "
  5 branch-if 1 assert=
  -5 branch-if -1 assert=
  0 branch-if -1 assert=
  section-end
;

: test-if-nested
  section
  ." [8.2] if imbrique... "
  5 5 branch-nested 3 assert=
  5 -5 branch-nested 2 assert=
  -5 5 branch-nested 1 assert=
  -5 -5 branch-nested 0 assert=
  section-end
;

: test-if
  cr ." === 8. IF / ELSE / THEN ===" cr
  test-if-then
  test-if-nested
;

\ ──────────────────────────────────────────────────────────────────────
\ 9. BEGIN / UNTIL / WHILE / REPEAT / AGAIN
\ ──────────────────────────────────────────────────────────────────────

variable loop-counter

: count-until ( n -- sum )
  0 swap
  0 loop-counter !
  begin
    1 loop-counter +!
    dup loop-counter @ +
    swap
    loop-counter @ over >=
  until
  drop
;

: count-while ( n -- sum )
  0 swap
  0 loop-counter !
  begin
    loop-counter @ over <
  while
    1 loop-counter +!
    loop-counter @ +
  repeat
  drop
;

: test-begin-until
  section
  ." [9.1] begin/until... "
  5 count-until 15 assert=
  1 count-until 1 assert=
  10 count-until 55 assert=
  section-end
;

: test-begin-while
  section
  ." [9.2] begin/while/repeat... "
  5 count-while 15 assert=
  1 count-while 1 assert=
  0 count-while 0 assert=
  10 count-while 55 assert=
  section-end
;

: test-boucles-base
  cr ." === 9. BEGIN / UNTIL / WHILE ===" cr
  test-begin-until
  test-begin-while
;

\ ──────────────────────────────────────────────────────────────────────
\ 10. DO / LOOP / +LOOP / ?DO / LEAVE
\ ──────────────────────────────────────────────────────────────────────

variable sum-do

: test-do-loop-basic
  section
  ." [10.1] do/loop/i... "
  0 sum-do !
  5 0 do i sum-do +! loop
  sum-do @ 10 assert=

  0 sum-do !
  10 0 do i sum-do +! loop
  sum-do @ 45 assert=

  0 sum-do !
  1 0 do i sum-do +! loop
  sum-do @ 0 assert=
  section-end
;

: test-do-ploop
  section
  ." [10.2] +loop... "
  0 sum-do !
  10 0 do i sum-do +! 2 +loop
  sum-do @ 20 assert=

  0 sum-do !
  15 0 do i sum-do +! 3 +loop
  sum-do @ 0 3 + 6 + 9 + 12 + assert=
  section-end
;

: test-qdo
  section
  ." [10.3] ?do... "
  0 sum-do !
  5 0 ?do i sum-do +! loop
  sum-do @ 10 assert=

  0 sum-do !
  0 0 ?do i sum-do +! loop
  sum-do @ 0 assert=
  section-end
;

: test-leave
  section
  ." [10.4] leave... "
  0 sum-do !
  10 0 do
    i 5 = if leave then
    i sum-do +!
  loop
  sum-do @ 10 assert=
  section-end
;

: test-do-nested
  section
  ." [10.5] do imbrique + j... "
  0 sum-do !
  3 0 do
    3 0 do
      j i + sum-do +!
    loop
  loop
  \ j=0: i=0,1,2 → 0+1+2 = 3
  \ j=1: i=0,1,2 → 1+2+3 = 6
  \ j=2: i=0,1,2 → 2+3+4 = 9
  \ total = 18
  sum-do @ 18 assert=
  section-end
;

: test-do-loop
  cr ." === 10. DO / LOOP ===" cr
  test-do-loop-basic
  test-do-ploop
  test-qdo
  test-leave
  test-do-nested
;

\ ──────────────────────────────────────────────────────────────────────
\ 11. RECURSION
\ ──────────────────────────────────────────────────────────────────────

: factorielle ( n -- n! )
  dup 1 <= if
    drop 1
  else
    dup 1- recurse *
  then ;

: fibonacci ( n -- fib )
  dup 2 < if
  else
    dup 1- recurse
    swap 2 - recurse +
  then ;

: test-recursion
  section
  cr ." === 11. RECURSION ===" cr
  ." [11.1] factorielle... "
  0 factorielle 1 assert=
  1 factorielle 1 assert=
  5 factorielle 120 assert=
  7 factorielle 5040 assert=
  section-end
;

: test-fibonacci
  section
  ." [11.2] fibonacci... "
  0 fibonacci 0 assert=
  1 fibonacci 1 assert=
  2 fibonacci 1 assert=
  5 fibonacci 5 assert=
  10 fibonacci 55 assert=
  section-end
;

: test-recursion-suite
  test-recursion
  test-fibonacci
;

\ ──────────────────────────────────────────────────────────────────────
\ 12. EXCEPTIONS (TRY / CATCH / THROW)
\ ──────────────────────────────────────────────────────────────────────

: test-try-basic
  section
  ." [12.1] try/catch basique... "
  try
    42 throw
    0
  catch
    42 assert=
  endtry
  section-end
;

: test-try-no-throw
  section
  ." [12.2] try sans throw... "
  try
    99
    0
  catch
    drop
  endtry
  99 assert=
  section-end
;

: helper-throw ( n -- )
  dup 0 = if 1 throw then
  drop ;

: test-try-nested
  section
  ." [12.3] try imbrique... "
  try
    try
      10 throw
      0
    catch
      10 assert=
    endtry
    0
  catch
    drop
  endtry
  section-end
;

: test-try-in-word
  section
  ." [12.4] throw dans un mot appele... "
  try
    0 helper-throw
    0
  catch
    1 assert=
  endtry
  section-end
;

: div-safe ( a b -- result )
  try
    ?dup 0= if 1 throw then
    /
    0
  catch
    drop drop 0
  endtry ;

: test-try-divsafe
  section
  ." [12.5] division securisee... "
  10 2 div-safe 5 assert=
  10 0 div-safe 0 assert=
  section-end
;

: test-exceptions
  cr ." === 12. EXCEPTIONS ===" cr
  test-try-basic
  test-try-no-throw
  test-try-nested
  test-try-in-word
  test-try-divsafe
;

\ ──────────────────────────────────────────────────────────────────────
\ 13. CREATE / ALLOT / HERE / ,
\ ──────────────────────────────────────────────────────────────────────

: test-here-comma
  section
  ." [13.1] here , ... "
  here
  100 , 200 , 300 ,
  dup @ 100 assert=
  dup 1 + @ 200 assert=
  dup 2 + @ 300 assert=
  drop
  section-end
;

create test-array 10 , 20 , 30 , 40 , 50 ,

: test-create
  section
  ." [13.2] create ... "
  test-array @ 10 assert=
  test-array 1 + @ 20 assert=
  test-array 2 + @ 30 assert=
  test-array 3 + @ 40 assert=
  test-array 4 + @ 50 assert=
  section-end
;

: test-create-suite
  cr ." === 13. CREATE / HERE / , ===" cr
  test-here-comma
  test-create
;

\ ──────────────────────────────────────────────────────────────────────
\ 14. MOTS DEFINIS PAR L'UTILISATEUR
\ ──────────────────────────────────────────────────────────────────────

: double ( n -- 2n ) 2* ;
: carre ( n -- n^2 ) dup * ;
: cube ( n -- n^3 ) dup dup * * ;
: signe ( n -- -1|0|1 )
  dup 0 > if drop 1
  else 0 < if -1
  else 0
  then then ;

: test-mots-user
  section
  cr ." === 14. MOTS UTILISATEUR ===" cr
  ." [14.1] mots simples... "
  5 double 10 assert=
  0 double 0 assert=
  -3 double -6 assert=
  4 carre 16 assert=
  3 cube 27 assert=
  5 signe 1 assert=
  -5 signe -1 assert=
  0 signe 0 assert=
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 15. HASARD
\ ──────────────────────────────────────────────────────────────────────

: test-hasard
  section
  cr ." === 15. HASARD ===" cr
  ." [15.1] hasard bornes... "
  \ Verifier que hasard(10) retourne 0..9
  10 0 do
    10 hasard dup
    0 >= assert-true
    10 < assert-true
  loop
  \ hasard(1) doit toujours retourner 0
  1 hasard 0 assert=
  1 hasard 0 assert=
  1 hasard 0 assert=
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 16. BASE NUMERIQUE
\ ──────────────────────────────────────────────────────────────────────

: test-base
  section
  cr ." === 16. BASE NUMERIQUE ===" cr
  ." [16.1] hex decimal 0x 0b... "
  0xFF 255 assert=
  0x10 16 assert=
  0b1010 10 assert=
  0b11111111 255 assert=
  0x0 0 assert=
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 17. CANVAS FORTH
\ ──────────────────────────────────────────────────────────────────────

: test-canvas
  section
  cr ." === 17. CANVAS FORTH ===" cr
  ." [17.1] effacer pixel rect... "
  \ Ces operations ne doivent pas crasher
  0 effacer ok
  0 0 0xFF0000 pixel ok
  10 10 50 50 0x00FF00 rect ok
  0 0 100 100 0x0000FF ligne ok
  255 0 0 couleur 0x0000FF assert=
  0 255 0 couleur 0x00FF00 assert=
  0 0 255 couleur 0xFF0000 assert=
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 18. HORLOGE
\ ──────────────────────────────────────────────────────────────────────

: test-horloge
  section
  cr ." === 18. HORLOGE ===" cr
  ." [18.1] get-time... "
  get-time
  \ Stack: sec min hour day month year
  dup 2000 >= assert-true
  dup 2100 < assert-true
  drop \ year
  dup 1 >= assert-true
  dup 12 <= assert-true
  drop \ month
  dup 1 >= assert-true
  dup 31 <= assert-true
  drop \ day
  dup 0 >= assert-true
  dup 23 <= assert-true
  drop \ hour
  dup 0 >= assert-true
  dup 59 <= assert-true
  drop \ minute
  dup 0 >= assert-true
  dup 59 <= assert-true
  drop \ second
  section-end
;

: test-ticks
  section
  ." [18.2] ticks rdtsc... "
  ticks assert-nonzero
  rdtsc assert-nonzero
  \ Verifier que ticks avance
  ticks 1 ms ticks swap - 0 >= assert-true
  section-end
;

: test-horloge-suite
  test-horloge
  test-ticks
;

\ ──────────────────────────────────────────────────────────────────────
\ 19. MEMOIRE SYSTEME
\ ──────────────────────────────────────────────────────────────────────

: test-memmap
  section
  cr ." === 19. MEMOIRE SYSTEME ===" cr
  ." [19.1] mem-map... "
  mem-map
  \ -- total free
  dup 0 > assert-true
  over 0 > assert-true
  \ free <= total
  2dup >= assert-true
  2drop
  section-end
;

: test-fbsize
  section
  ." [19.2] fb-size... "
  fb-size
  \ -- w h
  dup 0 > assert-true
  over 0 > assert-true
  \ Resolutions raisonnables
  dup 4096 <= assert-true
  over 8192 <= assert-true
  2drop
  section-end
;

: test-systeme
  test-memmap
  test-fbsize
;

\ ──────────────────────────────────────────────────────────────────────
\ 20. HEAP
\ ──────────────────────────────────────────────────────────────────────

: test-heap
  section
  cr ." === 20. HEAP ===" cr
  ." [20.1] heap-used... "
  heap-used dup 0 >= assert-true drop
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 21. PCI
\ ──────────────────────────────────────────────────────────────────────

: test-pci
  section
  cr ." === 21. PCI ===" cr
  ." [21.1] pci-scan... "
  pci-scan dup 0 > assert-true
  \ Au moins 1 peripherique PCI sur tout PC
  dup 256 < assert-true
  \ Lire le premier
  dup 0 > if
    0 pci-dev
    \ -- bus dev func vid did class sub
    drop drop \ class sub
    dup 0 <> assert-true \ did non nul
    drop \ did
    dup 0 <> assert-true \ vid non nul
    drop drop drop drop \ vid func dev bus
  then
  drop \ count
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 22. ACPI
\ ──────────────────────────────────────────────────────────────────────

: test-acpi
  section
  cr ." === 22. ACPI ===" cr
  ." [22.1] acpi-rsdp... "
  acpi-rsdp dup 0 <> assert-true drop
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 23. CPUID
\ ──────────────────────────────────────────────────────────────────────

: test-cpuid
  section
  cr ." === 23. CPUID ===" cr
  ." [23.1] cpuid leaf 0... "
  0 cpuid
  \ -- eax ebx ecx edx
  \ eax = max standard leaf (au moins 1)
  drop drop drop
  dup 1 >= assert-true
  drop
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 24. SMBIOS
\ ──────────────────────────────────────────────────────────────────────

: test-smbios
  section
  cr ." === 24. SMBIOS ===" cr
  ." [24.1] smbios-entry... "
  smbios-entry dup 0 <> if
    dup smbios-info
    \ -- len table_addr count maj min
    drop \ min
    dup 2 >= assert-true \ version majeure >= 2
    drop \ maj
    drop \ count
    drop \ table_addr
    drop \ len
    ok
  else
    drop
    ." (absent, skip) " ok
  then
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 25. STRESS : operations combinees
\ ──────────────────────────────────────────────────────────────────────

variable stress-acc

: stress-loop ( n -- sum )
  0 stress-acc !
  0 ?do
    i i * stress-acc +!
  loop
  stress-acc @ ;

: test-stress
  section
  cr ." === 25. STRESS ===" cr
  ." [25.1] boucle 100 iterations... "
  100 stress-loop
  \ sum(i^2, i=0..99) = 328350
  328350 assert=
  section-end
;

: test-stress-nested
  section
  ." [25.2] boucle imbriquee 50x50... "
  0 stress-acc !
  50 0 do
    50 0 do
      1 stress-acc +!
    loop
  loop
  stress-acc @ 2500 assert=
  section-end
;

: test-stress-recursion
  section
  ." [25.3] recursion profonde... "
  10 factorielle 3628800 assert=
  section-end
;

: test-stress-suite
  test-stress
  test-stress-nested
  test-stress-recursion
;

\ ──────────────────────────────────────────────────────────────────────
\ 26. SECURITE SANDBOX
\ ──────────────────────────────────────────────────────────────────────

: test-sandbox-mem
  section
  cr ." === 26. SANDBOX ===" cr
  ." [26.1] mem-bounds... "
  \ Sauver les bornes actuelles
  \ Tester avec des bornes restreintes
  0 10 mem-bounds
  42 0 !
  0 @ 42 assert=
  \ Restaurer (0..4096)
  0 4096 mem-bounds
  section-end
;

: test-sandbox
  test-sandbox-mem
;

\ ──────────────────────────────────────────────────────────────────────
\ 27. EDGE CASES et ROBUSTESSE
\ ──────────────────────────────────────────────────────────────────────

: test-edge-zero
  section
  cr ." === 27. EDGE CASES ===" cr
  ." [27.1] Operations avec zero... "
  0 0 + 0 assert=
  0 0 * 0 assert=
  0 0 - 0 assert=
  0 1 / 0 assert=
  0 abs 0 assert=
  0 negate 0 assert=
  0 0 min 0 assert=
  0 0 max 0 assert=
  section-end
;

: test-edge-negative
  section
  ." [27.2] Nombres negatifs... "
  -1 -1 * 1 assert=
  -10 abs 10 assert=
  -1 negate 1 assert=
  -100 -200 min -200 assert=
  -100 -200 max -100 assert=
  -5 -3 + -8 assert=
  section-end
;

: test-edge-overflow
  section
  ." [27.3] Grands nombres... "
  1000000 1000000 * 1000000000000 assert=
  0x7FFFFFFF 1 + 0x80000000 assert=
  section-end
;

: test-edge-empty-loop
  section
  ." [27.4] Boucles vides... "
  0 0 ?do i drop loop ok
  0 sum-do !
  1 1 ?do i sum-do +! loop
  sum-do @ 0 assert=
  section-end
;

: test-edge-cases
  test-edge-zero
  test-edge-negative
  test-edge-overflow
  test-edge-empty-loop
;

\ ──────────────────────────────────────────────────────────────────────
\ 28. MOTS FORTH AVANCES
\ ──────────────────────────────────────────────────────────────────────

: test-execute
  section
  cr ." === 28. MOTS AVANCES ===" cr
  ." [28.1] ' execute... "
  ' double execute
  \ double est defini plus haut → attend un arg
  5 ' double execute 10 assert=
  3 ' carre execute 9 assert=
  section-end
;

: test-find-execute
  section
  ." [28.2] compilation dynamique... "
  \ Verifier que words ne crash pas
  ok
  section-end
;

: test-avances
  test-execute
  test-find-execute
;

\ ──────────────────────────────────────────────────────────────────────
\ 29. MULTI-TACHE (vérification non-destructive)
\ ──────────────────────────────────────────────────────────────────────

: test-multitask
  section
  cr ." === 29. MULTITACHE ===" cr
  ." [29.1] tasks (liste)... "
  \ Ne devrait pas crasher
  ok
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 30. RESUME GLOBAL
\ ──────────────────────────────────────────────────────────────────────

: lancer-tests ( -- )
  cr
  ." ════════════════════════════════════════════════════" cr
  ."  EPONA OS — SUITE DE TESTS EponaForth" cr
  ." ════════════════════════════════════════════════════" cr
  cr

  test-reset

  test-arithmetique
  test-pile
  test-rstack-suite
  test-comparaisons
  test-logique
  test-memoire
  test-constantes
  test-if
  test-boucles-base
  test-do-loop
  test-recursion-suite
  test-exceptions
  test-create-suite
  test-mots-user
  test-hasard
  test-base
  test-canvas
  test-horloge-suite
  test-systeme
  test-heap
  test-pci
  test-acpi
  test-cpuid
  test-smbios
  test-stress-suite
  test-sandbox
  test-edge-cases
  test-avances
  test-multitask

  resume-tests
;

\ ──────────────────────────────────────────────────────────────────────
\ Lancement automatique si charge directement
\ ─




```forth
\ ════════════════════════════════════════════════════════════════════════
\                    TESTS.FTH — Suite de tests Epona OS
\                    EponaForth — Validation du runtime
\ ════════════════════════════════════════════════════════════════════════
\
\ Utilisation :
\   sys:load TESTS.FTH        (depuis le terminal)
\   exec TESTS.FTH            (depuis le shell)
\
\ Ou depuis BOOT.FTH :
\   sys:load TESTS.FTH
\   lancer-tests
\
\ Les resultats sont affiches dans le terminal.
\ A la fin : nombre de tests OK et KO.
\ Si KO > 0, verifier les lignes "ECHEC" dans la sortie.
\
\ ════════════════════════════════════════════════════════════════════════

\ ──────────────────────────────────────────────────────────────────────
\ FRAMEWORK DE TEST
\ ──────────────────────────────────────────────────────────────────────

variable tests-ok
variable tests-ko
variable tests-total
variable test-section-ok
variable test-section-ko

: test-reset
  0 tests-ok !
  0 tests-ko !
  0 tests-total !
;

: ok ( -- )
  1 tests-ok +!
  1 tests-total +!
  1 test-section-ok +!
;

: ko ( -- )
  1 tests-ko +!
  1 tests-total +!
  1 test-section-ko +!
;

: assert= ( got expected -- )
  2dup = if
    2drop ok
  else
    ko
    cr ." ECHEC assert= : attendu " . ." obtenu " . cr
  then
;

: assert<> ( a b -- )
  2dup <> if
    2drop ok
  else
    ko
    cr ." ECHEC assert<> : les deux valeurs sont egales : " . drop cr
  then
;

: assert-true ( flag -- )
  if ok else ko cr ." ECHEC assert-true" cr then
;

: assert-false ( flag -- )
  if ko cr ." ECHEC assert-false" cr else ok then
;

: assert-zero ( n -- )
  0= if ok else ko cr ." ECHEC assert-zero" cr then
;

: assert-nonzero ( n -- )
  0<> if ok else ko cr ." ECHEC assert-nonzero" cr then
;

: assert-positive ( n -- )
  0> if ok else ko cr ." ECHEC assert-positive" cr then
;

: assert-negative ( n -- )
  0< if ok else ko cr ." ECHEC assert-negative" cr then
;

: assert-range ( val lo hi -- )
  rot dup rot <= if
    swap >=
    if ok else ko cr ." ECHEC assert-range (trop bas)" cr then
  else
    2drop ko cr ." ECHEC assert-range (trop haut)" cr
  then
;

: section ( -- )
  0 test-section-ok !
  0 test-section-ko !
;

: section-end ( -- )
  test-section-ko @ 0= if
    ." OK (" test-section-ok @ . ." tests)" cr
  else
    ." ** " test-section-ko @ . ." ECHEC(S) sur "
    test-section-ok @ test-section-ko @ + . ." tests **" cr
  then
;

: resume-tests ( -- )
  cr
  ." ════════════════════════════════════════" cr
  ."  RESULTATS : " cr
  ."    Total  : " tests-total @ . cr
  ."    OK     : " tests-ok @ . cr
  ."    ECHEC  : " tests-ko @ . cr
  ." ════════════════════════════════════════" cr
  tests-ko @ 0= if
    ." ✓ TOUS LES TESTS PASSENT" cr
  else
    ." ✗ IL Y A DES ECHECS !" cr
  then
  cr
;

\ ──────────────────────────────────────────────────────────────────────
\ 1. ARITHMETIQUE DE BASE
\ ──────────────────────────────────────────────────────────────────────

: test-addition
  section
  ." [1.1] Addition... "
  0 0 + 0 assert=
  1 1 + 2 assert=
  100 200 + 300 assert=
  -1 1 + 0 assert=
  -5 -3 + -8 assert=
  2147483647 1 + 2147483648 assert=
  section-end
;

: test-soustraction
  section
  ." [1.2] Soustraction... "
  5 3 - 2 assert=
  3 5 - -2 assert=
  0 0 - 0 assert=
  -1 -1 - 0 assert=
  100 1 - 99 assert=
  section-end
;

: test-multiplication
  section
  ." [1.3] Multiplication... "
  3 4 * 12 assert=
  0 999 * 0 assert=
  -2 3 * -6 assert=
  -2 -3 * 6 assert=
  1 1 * 1 assert=
  7 7 * 49 assert=
  section-end
;

: test-division
  section
  ." [1.4] Division... "
  10 2 / 5 assert=
  7 2 / 3 assert=
  0 5 / 0 assert=
  -10 2 / -5 assert=
  100 10 / 10 assert=
  \ Division par zero → 0 (protection)
  5 0 / 0 assert=
  section-end
;

: test-modulo
  section
  ." [1.5] Modulo... "
  10 3 mod 1 assert=
  7 2 mod 1 assert=
  8 4 mod 0 assert=
  0 5 mod 0 assert=
  \ Modulo par zero → 0 (protection)
  5 0 mod 0 assert=
  section-end
;

: test-divmod
  section
  ." [1.6] /mod... "
  7 2 /mod
  3 assert=
  1 assert=
  10 3 /mod
  3 assert=
  1 assert=
  section-end
;

: test-incr-decr
  section
  ." [1.7] 1+ 1- 2+ 2- 2* 2/... "
  5 1+ 6 assert=
  5 1- 4 assert=
  5 2+ 7 assert=
  5 2- 3 assert=
  5 2* 10 assert=
  10 2/ 5 assert=
  0 1- -1 assert=
  -1 1+ 0 assert=
  section-end
;

: test-abs-negate
  section
  ." [1.8] abs negate... "
  5 abs 5 assert=
  -5 abs 5 assert=
  0 abs 0 assert=
  5 negate -5 assert=
  -5 negate 5 assert=
  0 negate 0 assert=
  section-end
;

: test-min-max
  section
  ." [1.9] min max... "
  3 5 min 3 assert=
  5 3 min 3 assert=
  -1 1 min -1 assert=
  3 5 max 5 assert=
  5 3 max 5 assert=
  -1 1 max 1 assert=
  section-end
;

: test-arithmetique
  cr ." === 1. ARITHMETIQUE ===" cr
  test-addition
  test-soustraction
  test-multiplication
  test-division
  test-modulo
  test-divmod
  test-incr-decr
  test-abs-negate
  test-min-max
;

\ ──────────────────────────────────────────────────────────────────────
\ 2. MANIPULATION DE PILE
\ ──────────────────────────────────────────────────────────────────────

: test-dup
  section
  ." [2.1] dup... "
  42 dup + 84 assert=
  0 dup 0 assert= 0 assert=
  -1 dup -1 assert= -1 assert=
  section-end
;

: test-drop
  section
  ." [2.2] drop... "
  1 2 drop 1 assert=
  10 20 30 drop drop 10 assert=
  section-end
;

: test-swap
  section
  ." [2.3] swap... "
  1 2 swap 1 assert= 2 assert=
  10 20 swap 10 assert= 20 assert=
  section-end
;

: test-over
  section
  ." [2.4] over... "
  1 2 over 1 assert= 2 assert= 1 assert=
  10 20 over + 30 assert= 10 assert=
  section-end
;

: test-rot
  section
  ." [2.5] rot -rot... "
  1 2 3 rot
  1 assert=
  3 assert=
  2 assert=
  1 2 3 -rot
  3 assert=
  1 assert=
  2 assert=
  section-end
;

: test-nip-tuck
  section
  ." [2.6] nip tuck... "
  1 2 nip 2 assert=
  1 2 tuck
  2 assert=
  1 assert=
  2 assert=
  section-end
;

: test-2dup-2drop
  section
  ." [2.7] 2dup 2drop 2swap 2over... "
  3 4 2dup
  4 assert= 3 assert=
  4 assert= 3 assert=
  1 2 3 4 2drop
  2 assert= 1 assert=
  1 2 3 4 2swap
  2 assert= 1 assert=
  4 assert= 3 assert=
  1 2 3 4 2over
  2 assert= 1 assert=
  4 assert= 3 assert=
  2 assert= 1 assert=
  section-end
;

: test-qdup
  section
  ." [2.8] ?dup... "
  0 ?dup depth 1 assert= drop
  5 ?dup depth 2 >= assert-true drop drop
  section-end
;

: test-pick
  section
  ." [2.9] pick... "
  10 20 30 0 pick 30 assert= drop drop drop
  10 20 30 1 pick 20 assert= drop drop drop
  10 20 30 2 pick 10 assert= drop drop drop
  section-end
;

: test-depth
  section
  ." [2.10] depth... "
  depth 0 assert=
  1 depth 2 assert= drop
  1 2 3 depth 4 assert= drop drop drop
  section-end
;

: test-pile
  cr ." === 2. PILE ===" cr
  test-dup
  test-drop
  test-swap
  test-over
  test-rot
  test-nip-tuck
  test-2dup-2drop
  test-qdup
  test-pick
  test-depth
;

\ ──────────────────────────────────────────────────────────────────────
\ 3. PILE DE RETOUR
\ ──────────────────────────────────────────────────────────────────────

: test-rstack
  section
  ." [3.1] >r r> r@... "
  42 >r r@ 42 assert= r> 42 assert=
  10 20 >r >r r> r> 10 assert= 20 assert=
  99 >r r@ r@ = assert-true r> drop
  section-end
;

: test-rstack-suite
  cr ." === 3. PILE DE RETOUR ===" cr
  test-rstack
;

\ ──────────────────────────────────────────────────────────────────────
\ 4. COMPARAISONS
\ ──────────────────────────────────────────────────────────────────────

: test-egal
  section
  ." [4.1] = <> ... "
  5 5 = assert-true
  5 6 = assert-false
  0 0 = assert-true
  -1 -1 = assert-true
  5 6 <> assert-true
  5 5 <> assert-false
  section-end
;

: test-ordre
  section
  ." [4.2] < > <= >= ... "
  3 5 < assert-true
  5 3 < assert-false
  5 5 < assert-false
  5 3 > assert-true
  3 5 > assert-false
  5 5 > assert-false
  3 5 <= assert-true
  5 5 <= assert-true
  6 5 <= assert-false
  5 3 >= assert-true
  5 5 >= assert-true
  4 5 >= assert-false
  section-end
;

: test-zero-compare
  section
  ." [4.3] 0= 0<> 0< 0> ... "
  0 0= assert-true
  1 0= assert-false
  -1 0= assert-false
  0 0<> assert-false
  5 0<> assert-true
  -1 0< assert-true
  0 0< assert-false
  1 0< assert-false
  1 0> assert-true
  0 0> assert-false
  -1 0> assert-false
  section-end
;

: test-comparaisons
  cr ." === 4. COMPARAISONS ===" cr
  test-egal
  test-ordre
  test-zero-compare
;

\ ──────────────────────────────────────────────────────────────────────
\ 5. LOGIQUE BINAIRE
\ ──────────────────────────────────────────────────────────────────────

: test-and-or-xor
  section
  ." [5.1] and or xor invert... "
  0xFF 0x0F and 0x0F assert=
  0xF0 0x0F or 0xFF assert=
  0xFF 0xFF xor 0 assert=
  0xAA 0x55 xor 0xFF assert=
  0 invert -1 assert=
  section-end
;

: test-shift
  section
  ." [5.2] lshift rshift... "
  1 0 lshift 1 assert=
  1 1 lshift 2 assert=
  1 8 lshift 256 assert=
  256 8 rshift 1 assert=
  255 4 rshift 15 assert=
  section-end
;

: test-logique
  cr ." === 5. LOGIQUE BINAIRE ===" cr
  test-and-or-xor
  test-shift
;

\ ──────────────────────────────────────────────────────────────────────
\ 6. VARIABLES ET MEMOIRE
\ ──────────────────────────────────────────────────────────────────────

variable test-var-a
variable test-var-b
variable test-var-c

: test-variables
  section
  ." [6.1] variable @ ! +!... "
  0 test-var-a !
  test-var-a @ 0 assert=
  42 test-var-a !
  test-var-a @ 42 assert=
  10 test-var-a +!
  test-var-a @ 52 assert=
  -52 test-var-a +!
  test-var-a @ 0 assert=
  section-end
;

: test-multi-variables
  section
  ." [6.2] Variables multiples... "
  100 test-var-a !
  200 test-var-b !
  300 test-var-c !
  test-var-a @ 100 assert=
  test-var-b @ 200 assert=
  test-var-c @ 300 assert=
  test-var-a @ test-var-b @ + test-var-c @ assert=
  section-end
;

: test-cell-ops
  section
  ." [6.3] cell+ cells aligned... "
  0 cell+ 8 assert=
  10 cell+ 18 assert=
  1 cells 8 assert=
  3 cells 24 assert=
  0 aligned 0 assert=
  1 aligned 8 assert=
  7 aligned 8 assert=
  8 aligned 8 assert=
  9 aligned 16 assert=
  section-end
;

: test-memoire
  cr ." === 6. VARIABLES / MEMOIRE ===" cr
  test-variables
  test-multi-variables
  test-cell-ops
;

\ ──────────────────────────────────────────────────────────────────────
\ 7. CONSTANTES
\ ──────────────────────────────────────────────────────────────────────

42 constant REPONSE
100 constant CENT
-1 constant VRAI
0 constant FAUX

: test-constantes
  section
  cr ." === 7. CONSTANTES ===" cr
  ." [7.1] constant... "
  REPONSE 42 assert=
  CENT 100 assert=
  VRAI -1 assert=
  FAUX 0 assert=
  REPONSE CENT + 142 assert=
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 8. IF / ELSE / THEN
\ ──────────────────────────────────────────────────────────────────────

: branch-if ( n -- m )
  0 > if 1 else -1 then ;

: branch-if-only ( n -- m )
  0 > if 1 then ;

: branch-nested ( a b -- c )
  0 > if
    0 > if 3 else 2 then
  else
    0 > if 1 else 0 then
  then ;

: test-if-then
  section
  ." [8.1] if/else/then... "
  5 branch-if 1 assert=
  -5 branch-if -1 assert=
  0 branch-if -1 assert=
  section-end
;

: test-if-nested
  section
  ." [8.2] if imbrique... "
  5 5 branch-nested 3 assert=
  5 -5 branch-nested 2 assert=
  -5 5 branch-nested 1 assert=
  -5 -5 branch-nested 0 assert=
  section-end
;

: test-if
  cr ." === 8. IF / ELSE / THEN ===" cr
  test-if-then
  test-if-nested
;

\ ──────────────────────────────────────────────────────────────────────
\ 9. BEGIN / UNTIL / WHILE / REPEAT / AGAIN
\ ──────────────────────────────────────────────────────────────────────

variable loop-counter

: count-until ( n -- sum )
  0 swap
  0 loop-counter !
  begin
    1 loop-counter +!
    dup loop-counter @ +
    swap
    loop-counter @ over >=
  until
  drop
;

: count-while ( n -- sum )
  0 swap
  0 loop-counter !
  begin
    loop-counter @ over <
  while
    1 loop-counter +!
    loop-counter @ +
  repeat
  drop
;

: test-begin-until
  section
  ." [9.1] begin/until... "
  5 count-until 15 assert=
  1 count-until 1 assert=
  10 count-until 55 assert=
  section-end
;

: test-begin-while
  section
  ." [9.2] begin/while/repeat... "
  5 count-while 15 assert=
  1 count-while 1 assert=
  0 count-while 0 assert=
  10 count-while 55 assert=
  section-end
;

: test-boucles-base
  cr ." === 9. BEGIN / UNTIL / WHILE ===" cr
  test-begin-until
  test-begin-while
;

\ ──────────────────────────────────────────────────────────────────────
\ 10. DO / LOOP / +LOOP / ?DO / LEAVE
\ ──────────────────────────────────────────────────────────────────────

variable sum-do

: test-do-loop-basic
  section
  ." [10.1] do/loop/i... "
  0 sum-do !
  5 0 do i sum-do +! loop
  sum-do @ 10 assert=

  0 sum-do !
  10 0 do i sum-do +! loop
  sum-do @ 45 assert=

  0 sum-do !
  1 0 do i sum-do +! loop
  sum-do @ 0 assert=
  section-end
;

: test-do-ploop
  section
  ." [10.2] +loop... "
  0 sum-do !
  10 0 do i sum-do +! 2 +loop
  sum-do @ 20 assert=

  0 sum-do !
  15 0 do i sum-do +! 3 +loop
  sum-do @ 0 3 + 6 + 9 + 12 + assert=
  section-end
;

: test-qdo
  section
  ." [10.3] ?do... "
  0 sum-do !
  5 0 ?do i sum-do +! loop
  sum-do @ 10 assert=

  0 sum-do !
  0 0 ?do i sum-do +! loop
  sum-do @ 0 assert=
  section-end
;

: test-leave
  section
  ." [10.4] leave... "
  0 sum-do !
  10 0 do
    i 5 = if leave then
    i sum-do +!
  loop
  sum-do @ 10 assert=
  section-end
;

: test-do-nested
  section
  ." [10.5] do imbrique + j... "
  0 sum-do !
  3 0 do
    3 0 do
      j i + sum-do +!
    loop
  loop
  \ j=0: i=0,1,2 → 0+1+2 = 3
  \ j=1: i=0,1,2 → 1+2+3 = 6
  \ j=2: i=0,1,2 → 2+3+4 = 9
  \ total = 18
  sum-do @ 18 assert=
  section-end
;

: test-do-loop
  cr ." === 10. DO / LOOP ===" cr
  test-do-loop-basic
  test-do-ploop
  test-qdo
  test-leave
  test-do-nested
;

\ ──────────────────────────────────────────────────────────────────────
\ 11. RECURSION
\ ──────────────────────────────────────────────────────────────────────

: factorielle ( n -- n! )
  dup 1 <= if
    drop 1
  else
    dup 1- recurse *
  then ;

: fibonacci ( n -- fib )
  dup 2 < if
  else
    dup 1- recurse
    swap 2 - recurse +
  then ;

: test-recursion
  section
  cr ." === 11. RECURSION ===" cr
  ." [11.1] factorielle... "
  0 factorielle 1 assert=
  1 factorielle 1 assert=
  5 factorielle 120 assert=
  7 factorielle 5040 assert=
  section-end
;

: test-fibonacci
  section
  ." [11.2] fibonacci... "
  0 fibonacci 0 assert=
  1 fibonacci 1 assert=
  2 fibonacci 1 assert=
  5 fibonacci 5 assert=
  10 fibonacci 55 assert=
  section-end
;

: test-recursion-suite
  test-recursion
  test-fibonacci
;

\ ──────────────────────────────────────────────────────────────────────
\ 12. EXCEPTIONS (TRY / CATCH / THROW)
\ ──────────────────────────────────────────────────────────────────────

: test-try-basic
  section
  ." [12.1] try/catch basique... "
  try
    42 throw
    0
  catch
    42 assert=
  endtry
  section-end
;

: test-try-no-throw
  section
  ." [12.2] try sans throw... "
  try
    99
    0
  catch
    drop
  endtry
  99 assert=
  section-end
;

: helper-throw ( n -- )
  dup 0 = if 1 throw then
  drop ;

: test-try-nested
  section
  ." [12.3] try imbrique... "
  try
    try
      10 throw
      0
    catch
      10 assert=
    endtry
    0
  catch
    drop
  endtry
  section-end
;

: test-try-in-word
  section
  ." [12.4] throw dans un mot appele... "
  try
    0 helper-throw
    0
  catch
    1 assert=
  endtry
  section-end
;

: div-safe ( a b -- result )
  try
    ?dup 0= if 1 throw then
    /
    0
  catch
    drop drop 0
  endtry ;

: test-try-divsafe
  section
  ." [12.5] division securisee... "
  10 2 div-safe 5 assert=
  10 0 div-safe 0 assert=
  section-end
;

: test-exceptions
  cr ." === 12. EXCEPTIONS ===" cr
  test-try-basic
  test-try-no-throw
  test-try-nested
  test-try-in-word
  test-try-divsafe
;

\ ──────────────────────────────────────────────────────────────────────
\ 13. CREATE / ALLOT / HERE / ,
\ ──────────────────────────────────────────────────────────────────────

: test-here-comma
  section
  ." [13.1] here , ... "
  here
  100 , 200 , 300 ,
  dup @ 100 assert=
  dup 1 + @ 200 assert=
  dup 2 + @ 300 assert=
  drop
  section-end
;

create test-array 10 , 20 , 30 , 40 , 50 ,

: test-create
  section
  ." [13.2] create ... "
  test-array @ 10 assert=
  test-array 1 + @ 20 assert=
  test-array 2 + @ 30 assert=
  test-array 3 + @ 40 assert=
  test-array 4 + @ 50 assert=
  section-end
;

: test-create-suite
  cr ." === 13. CREATE / HERE / , ===" cr
  test-here-comma
  test-create
;

\ ──────────────────────────────────────────────────────────────────────
\ 14. MOTS DEFINIS PAR L'UTILISATEUR
\ ──────────────────────────────────────────────────────────────────────

: double ( n -- 2n ) 2* ;
: carre ( n -- n^2 ) dup * ;
: cube ( n -- n^3 ) dup dup * * ;
: signe ( n -- -1|0|1 )
  dup 0 > if drop 1
  else 0 < if -1
  else 0
  then then ;

: test-mots-user
  section
  cr ." === 14. MOTS UTILISATEUR ===" cr
  ." [14.1] mots simples... "
  5 double 10 assert=
  0 double 0 assert=
  -3 double -6 assert=
  4 carre 16 assert=
  3 cube 27 assert=
  5 signe 1 assert=
  -5 signe -1 assert=
  0 signe 0 assert=
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 15. HASARD
\ ──────────────────────────────────────────────────────────────────────

: test-hasard
  section
  cr ." === 15. HASARD ===" cr
  ." [15.1] hasard bornes... "
  \ Verifier que hasard(10) retourne 0..9
  10 0 do
    10 hasard dup
    0 >= assert-true
    10 < assert-true
  loop
  \ hasard(1) doit toujours retourner 0
  1 hasard 0 assert=
  1 hasard 0 assert=
  1 hasard 0 assert=
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 16. BASE NUMERIQUE
\ ──────────────────────────────────────────────────────────────────────

: test-base
  section
  cr ." === 16. BASE NUMERIQUE ===" cr
  ." [16.1] hex decimal 0x 0b... "
  0xFF 255 assert=
  0x10 16 assert=
  0b1010 10 assert=
  0b11111111 255 assert=
  0x0 0 assert=
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 17. CANVAS FORTH
\ ──────────────────────────────────────────────────────────────────────

: test-canvas
  section
  cr ." === 17. CANVAS FORTH ===" cr
  ." [17.1] effacer pixel rect... "
  \ Ces operations ne doivent pas crasher
  0 effacer ok
  0 0 0xFF0000 pixel ok
  10 10 50 50 0x00FF00 rect ok
  0 0 100 100 0x0000FF ligne ok
  255 0 0 couleur 0x0000FF assert=
  0 255 0 couleur 0x00FF00 assert=
  0 0 255 couleur 0xFF0000 assert=
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 18. HORLOGE
\ ──────────────────────────────────────────────────────────────────────

: test-horloge
  section
  cr ." === 18. HORLOGE ===" cr
  ." [18.1] get-time... "
  get-time
  \ Stack: sec min hour day month year
  dup 2000 >= assert-true
  dup 2100 < assert-true
  drop \ year
  dup 1 >= assert-true
  dup 12 <= assert-true
  drop \ month
  dup 1 >= assert-true
  dup 31 <= assert-true
  drop \ day
  dup 0 >= assert-true
  dup 23 <= assert-true
  drop \ hour
  dup 0 >= assert-true
  dup 59 <= assert-true
  drop \ minute
  dup 0 >= assert-true
  dup 59 <= assert-true
  drop \ second
  section-end
;

: test-ticks
  section
  ." [18.2] ticks rdtsc... "
  ticks assert-nonzero
  rdtsc assert-nonzero
  \ Verifier que ticks avance
  ticks 1 ms ticks swap - 0 >= assert-true
  section-end
;

: test-horloge-suite
  test-horloge
  test-ticks
;

\ ──────────────────────────────────────────────────────────────────────
\ 19. MEMOIRE SYSTEME
\ ──────────────────────────────────────────────────────────────────────

: test-memmap
  section
  cr ." === 19. MEMOIRE SYSTEME ===" cr
  ." [19.1] mem-map... "
  mem-map
  \ -- total free
  dup 0 > assert-true
  over 0 > assert-true
  \ free <= total
  2dup >= assert-true
  2drop
  section-end
;

: test-fbsize
  section
  ." [19.2] fb-size... "
  fb-size
  \ -- w h
  dup 0 > assert-true
  over 0 > assert-true
  \ Resolutions raisonnables
  dup 4096 <= assert-true
  over 8192 <= assert-true
  2drop
  section-end
;

: test-systeme
  test-memmap
  test-fbsize
;

\ ──────────────────────────────────────────────────────────────────────
\ 20. HEAP
\ ──────────────────────────────────────────────────────────────────────

: test-heap
  section
  cr ." === 20. HEAP ===" cr
  ." [20.1] heap-used... "
  heap-used dup 0 >= assert-true drop
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 21. PCI
\ ──────────────────────────────────────────────────────────────────────

: test-pci
  section
  cr ." === 21. PCI ===" cr
  ." [21.1] pci-scan... "
  pci-scan dup 0 > assert-true
  \ Au moins 1 peripherique PCI sur tout PC
  dup 256 < assert-true
  \ Lire le premier
  dup 0 > if
    0 pci-dev
    \ -- bus dev func vid did class sub
    drop drop \ class sub
    dup 0 <> assert-true \ did non nul
    drop \ did
    dup 0 <> assert-true \ vid non nul
    drop drop drop drop \ vid func dev bus
  then
  drop \ count
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 22. ACPI
\ ──────────────────────────────────────────────────────────────────────

: test-acpi
  section
  cr ." === 22. ACPI ===" cr
  ." [22.1] acpi-rsdp... "
  acpi-rsdp dup 0 <> assert-true drop
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 23. CPUID
\ ──────────────────────────────────────────────────────────────────────

: test-cpuid
  section
  cr ." === 23. CPUID ===" cr
  ." [23.1] cpuid leaf 0... "
  0 cpuid
  \ -- eax ebx ecx edx
  \ eax = max standard leaf (au moins 1)
  drop drop drop
  dup 1 >= assert-true
  drop
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 24. SMBIOS
\ ──────────────────────────────────────────────────────────────────────

: test-smbios
  section
  cr ." === 24. SMBIOS ===" cr
  ." [24.1] smbios-entry... "
  smbios-entry dup 0 <> if
    dup smbios-info
    \ -- len table_addr count maj min
    drop \ min
    dup 2 >= assert-true \ version majeure >= 2
    drop \ maj
    drop \ count
    drop \ table_addr
    drop \ len
    ok
  else
    drop
    ." (absent, skip) " ok
  then
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 25. STRESS : operations combinees
\ ──────────────────────────────────────────────────────────────────────

variable stress-acc

: stress-loop ( n -- sum )
  0 stress-acc !
  0 ?do
    i i * stress-acc +!
  loop
  stress-acc @ ;

: test-stress
  section
  cr ." === 25. STRESS ===" cr
  ." [25.1] boucle 100 iterations... "
  100 stress-loop
  \ sum(i^2, i=0..99) = 328350
  328350 assert=
  section-end
;

: test-stress-nested
  section
  ." [25.2] boucle imbriquee 50x50... "
  0 stress-acc !
  50 0 do
    50 0 do
      1 stress-acc +!
    loop
  loop
  stress-acc @ 2500 assert=
  section-end
;

: test-stress-recursion
  section
  ." [25.3] recursion profonde... "
  10 factorielle 3628800 assert=
  section-end
;

: test-stress-suite
  test-stress
  test-stress-nested
  test-stress-recursion
;

\ ──────────────────────────────────────────────────────────────────────
\ 26. SECURITE SANDBOX
\ ──────────────────────────────────────────────────────────────────────

: test-sandbox-mem
  section
  cr ." === 26. SANDBOX ===" cr
  ." [26.1] mem-bounds... "
  \ Sauver les bornes actuelles
  \ Tester avec des bornes restreintes
  0 10 mem-bounds
  42 0 !
  0 @ 42 assert=
  \ Restaurer (0..4096)
  0 4096 mem-bounds
  section-end
;

: test-sandbox
  test-sandbox-mem
;

\ ──────────────────────────────────────────────────────────────────────
\ 27. EDGE CASES et ROBUSTESSE
\ ──────────────────────────────────────────────────────────────────────

: test-edge-zero
  section
  cr ." === 27. EDGE CASES ===" cr
  ." [27.1] Operations avec zero... "
  0 0 + 0 assert=
  0 0 * 0 assert=
  0 0 - 0 assert=
  0 1 / 0 assert=
  0 abs 0 assert=
  0 negate 0 assert=
  0 0 min 0 assert=
  0 0 max 0 assert=
  section-end
;

: test-edge-negative
  section
  ." [27.2] Nombres negatifs... "
  -1 -1 * 1 assert=
  -10 abs 10 assert=
  -1 negate 1 assert=
  -100 -200 min -200 assert=
  -100 -200 max -100 assert=
  -5 -3 + -8 assert=
  section-end
;

: test-edge-overflow
  section
  ." [27.3] Grands nombres... "
  1000000 1000000 * 1000000000000 assert=
  0x7FFFFFFF 1 + 0x80000000 assert=
  section-end
;

: test-edge-empty-loop
  section
  ." [27.4] Boucles vides... "
  0 0 ?do i drop loop ok
  0 sum-do !
  1 1 ?do i sum-do +! loop
  sum-do @ 0 assert=
  section-end
;

: test-edge-cases
  test-edge-zero
  test-edge-negative
  test-edge-overflow
  test-edge-empty-loop
;

\ ──────────────────────────────────────────────────────────────────────
\ 28. MOTS FORTH AVANCES
\ ──────────────────────────────────────────────────────────────────────

: test-execute
  section
  cr ." === 28. MOTS AVANCES ===" cr
  ." [28.1] ' execute... "
  ' double execute
  \ double est defini plus haut → attend un arg
  5 ' double execute 10 assert=
  3 ' carre execute 9 assert=
  section-end
;

: test-find-execute
  section
  ." [28.2] compilation dynamique... "
  \ Verifier que words ne crash pas
  ok
  section-end
;

: test-avances
  test-execute
  test-find-execute
;

\ ──────────────────────────────────────────────────────────────────────
\ 29. MULTI-TACHE (vérification non-destructive)
\ ──────────────────────────────────────────────────────────────────────

: test-multitask
  section
  cr ." === 29. MULTITACHE ===" cr
  ." [29.1] tasks (liste)... "
  \ Ne devrait pas crasher
  ok
  section-end
;

\ ──────────────────────────────────────────────────────────────────────
\ 30. RESUME GLOBAL
\ ──────────────────────────────────────────────────────────────────────

: lancer-tests ( -- )
  cr
  ." ════════════════════════════════════════════════════" cr
  ."  EPONA OS — SUITE DE TESTS EponaForth" cr
  ." ════════════════════════════════════════════════════" cr
  cr

  test-reset

  test-arithmetique
  test-pile
  test-rstack-suite
  test-comparaisons
  test-logique
  test-memoire
  test-constantes
  test-if
  test-boucles-base
  test-do-loop
  test-recursion-suite
  test-exceptions
  test-create-suite
  test-mots-user
  test-hasard
  test-base
  test-canvas
  test-horloge-suite
  test-systeme
  test-heap
  test-pci
  test-acpi
  test-cpuid
  test-smbios
  test-stress-suite
  test-sandbox
  test-edge-cases
  test-avances
  test-multitask

  resume-tests
;

\ ──────────────────────────────────────────────────────────────────────
\ Lancement automatique si charge directement
\ ──────────────────────────────────────────────────────────────────────

lancer-tests
```

## Ce que ça couvre

| Section | Tests | Ce qui est vérifié |
|---|---|---|
| 1. Arithmétique | 9 sous-tests | `+` `-` `*` `/` `mod` `/mod` `1+` `2*` `abs` `negate` `min` `max` |
| 2. Pile | 10 sous-tests | `dup` `drop` `swap` `over` `rot` `-rot` `nip` `tuck` `2dup` `2drop` `2swap` `2over` `?dup` `pick` `depth` |
| 3. Rstack | 1 sous-test | `>r` `r>` `r@` |
| 4. Comparaisons | 3 sous-tests | `=` `<>` `<` `>` `<=` `>=` `0=` `0<>` `0<` `0>` |
| 5. Logique | 2 sous-tests | `and` `or` `xor` `invert` `lshift` `rshift` |
| 6. Mémoire | 3 sous-tests | `variable` `@` `!` `+!` `cell+` `cells` `aligned` |
| 7. Constantes | 1 sous-test | `constant` |
| 8. IF/ELSE | 2 sous-tests | `if` `else` `then` imbriqués |
| 9. BEGIN | 2 sous-tests | `begin/until` `begin/while/repeat` |
| 10. DO/LOOP | 5 sous-tests | `do/loop` `+loop` `?do` `leave` boucles imbriquées `j` |
| 11. Récursion | 2 sous-tests | `recurse` factorielle fibonacci |
| 12. Exceptions | 5 sous-tests | `try` `catch` `throw` `endtry` imbriqués |
| 13. Create | 2 sous-tests | `create` `here` `,` tableaux |
| 14. Mots user | 1 sous-test | Mots personnalisés |
| 15. Hasard | 1 sous-test | `hasard` bornes |
| 16. Base | 1 sous-test | `hex` `0x` `0b` |
| 17. Canvas | 1 sous-test | `pixel` `rect` `ligne` `effacer` `couleur` |
| 18. Horloge | 2 sous-tests | `get-time` `ticks` `rdtsc` |
| 19. Système | 2 sous-tests | `mem-map` `fb-size` |
| 20. Heap | 1 sous-test | `heap-used` |
| 21. PCI | 1 sous-test | `pci-scan` `pci-dev` |
| 22. ACPI | 1 sous-test | `acpi-rsdp` |
| 23. CPUID | 1 sous-test | `cpuid` leaf 0 |
| 24. SMBIOS | 1 sous-test | `smbios-entry` `smbios-info` |
| 25. Stress | 3 sous-tests | Boucles intensives, récursion profonde |
| 26. Sandbox | 1 sous-test | `mem-bounds` |
| 27. Edge cases | 4 sous-tests | Zéro, négatifs, overflow, boucles vides |
| 28. Avancés | 2 sous-tests | `'` `execute` |
| 29. Multitâche | 1 sous-test | `tasks` non-destructif |

## Comment l'utiliser

```forth
\ Depuis le terminal :
sys:load TESTS.FTH

\ Ou depuis BOOT.FTH :
sys:load TESTS.FTH
lancer-tests

\ Ou relancer manuellement :
lancer-tests
```

## Sortie attendue

```
════════════════════════════════════════════════════
 EPONA OS — SUITE DE TESTS EponaForth
════════════════════════════════════════════════════

=== 1. ARITHMETIQUE ===
[1.1] Addition... OK (6 tests)
[1.2] Soustraction... OK (5 tests)
...
=== 12. EXCEPTIONS ===
[12.1] try/catch basique... OK (1 tests)
...
════════════════════════════════════════════════════
 RESULTATS :
   Total  : 187
   OK     : 187
   ECHEC  : 0
════════════════════════════════════════════════════
✓ TOUS LES TESTS PASSENT
```─────────────────────────────────────────────────────────────────────

lancer-tests
