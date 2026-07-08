\ Test heap-used + while/repeat
\ sys:load TEST-HEAP.FTH

\ --- heap-used ---
heap-used . cr

: petit 1 2 3 . . . ;
heap-used . cr

: moyen 100 0 do i . loop ;
heap-used . cr

: moyen 500 0 do loop ;
heap-used . cr

\ --- while/repeat ---
\ Compte de 0 a 4   ( equivalent de : test 5 0 do i . loop ; )
: compte ( n -- )
  0 begin
    dup 5 < while
    dup . 1+
  repeat drop
;
cr ." 5 0 do i . loop  -> " 5 compte cr

\ Filter pairs seulement
: pairs ( n -- )
  0 begin
    dup 5 < while
    dup 2 mod 0= if dup . then
    1+
  repeat drop
;
cr ." Pairs de 0..5 -> " 5 pairs cr
