\ TEST-P1-PILE.FTH — Section 3.2 Pile
cr ." [3.2 Pile]" cr

variable ok  0 ok !
variable ko  0 ko !
: pass  1 ok +! ."  OK " ;
: fail  1 ko +! ."  FAIL " ;
: ?t ( n expected -- ) = if pass else fail then ;

." dup      " 42 dup 42 = swap 42 = and -1 = pass drop cr
." drop     " 1 2 drop 1 ?t cr
." swap     " 1 2 swap 1 ?t drop cr
." over     " 1 2 over 1 ?t 2drop cr
." rot      " 1 2 3 rot 1 ?t 2drop cr
." -rot     " 1 2 3 -rot 2 ?t 2drop cr
." nip      " 1 2 nip 2 ?t cr
." tuck     " 1 2 tuck 2 ?t drop drop cr
." 2dup     " 3 4 2dup 4 ?t 2drop drop cr
." 2drop    " 1 2 3 4 2drop 2 ?t drop cr
." 2swap    " 1 2 3 4 2swap 2 ?t 2drop drop cr
." 2over    " 1 2 3 4 2over 2 ?t 2drop 2drop drop cr
." ?dup nz  " 5 ?dup 5 ?t drop cr
." ?dup z   " 0 ?dup 0 ?t cr
." pick     " 10 20 30 1 pick 20 ?t 2drop drop cr
." depth    " 1 2 3 depth 3 ?t drop drop drop cr
." roll     " 10 20 30 40 2 roll 20 ?t drop drop drop cr
." .s       " 1 2 .s 2drop cr
." pile     " 10 20 pile 2drop cr

cr ." Pile: OK:" ok @ . ." FAIL:" ko @ . cr
