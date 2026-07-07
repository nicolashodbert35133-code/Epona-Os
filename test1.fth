\ Demo des nouveaux mots Forth (F5 = lance principal)

\ Definitions globales (en mode interprete, avant principal)

: test-loop 5 0 do i . loop cr ;
: fact dup 1 > if dup 1 - recurse * else drop 1 then ;
: make-counter create 0 , does> dup 1 swap +! ;
make-counter mycnt

: principal
  \ CONSTANT
  314 constant pi
  pi . cr

  \ CREATE / DOES> (compteur)
  mycnt . mycnt . mycnt . cr

  \ DO / LOOP
  test-loop

  \ RECURSE (factorielle)
  10 fact . cr

  \ HERE / ALLOT / ,
  here 10 allot
  0 here !  1 here 1 + !  2 here 2 + !
  here @ .  here 1 + @ .  here 2 + @ . cr

  \ WORDS
  words cr
;
