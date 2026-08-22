\ TEST-P1-MEM.FTH — Sections 3.4-3.7 Memoire
cr ." [3.4 Logique]" cr

variable ok  0 ok !
variable ko  0 ko !
: pass  1 ok +! ."  OK " ;
: fail  1 ko +! ."  FAIL " ;
: ?t ( n expected -- ) = if pass else fail then ;

." and      " 255 15 and 15 ?t cr
." or       " 240 15 or 255 ?t cr
." xor      " 255 15 xor 240 ?t cr
." invert   " 0 invert -1 ?t cr
." lshift   " 1 8 lshift 256 ?t cr
." rshift   " 256 4 rshift 16 ?t cr

cr ." [3.5 Memoire cell]" cr
variable t5m
." ! @      " 42 t5m ! t5m @ 42 ?t cr
." +!       " 10 t5m ! 5 t5m +! t5m @ 15 ?t cr
." 2! 2@    " variable t5d 1 allot  10 20 t5d 2! t5d 2@ 20 ?t nip cr
." cell     " cell 1 ?t cr
." cell+    " 100 cell+ 101 ?t cr
." cells    " 5 cells 5 ?t cr
." aligned  " 100 aligned 100 ?t cr
." char+    " 100 char+ 101 ?t cr
." chars    " 5 chars 5 ?t cr
." >body    " create t5b 10 allot  ' t5b >body 0> pass cr

cr ." [3.6 Octets]" cr
variable t6m
." c! c@    " 65 t6m c! t6m c@ 65 ?t cr
." w! w@    " 12345 t6m w! t6m w@ 12345 ?t cr
." l! l@    " 100000 t6m l! t6m l@ 100000 ?t cr

cr ." [3.7 Bloc]" cr
." fill     " here 10 42 fill here @ 42 ?t cr
." erase    " here 10 erase here @ 0 ?t cr
." blank    " pad 10 blank pad @ 32 ?t cr
." cmove    " here 5 99 fill  here here 5 + 5 cmove  here 5 + @ 99 ?t cr
." move     " here 5 88 fill  here here 10 + 5 move  here 10 + @ 88 ?t cr

cr ." Mem: OK:" ok @ . ." FAIL:" ko @ . cr
