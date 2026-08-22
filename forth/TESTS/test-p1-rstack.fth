\ TEST-P1-RSTACK.FTH — Section 3.8 R-stack + 3.9 Boucles
cr ." [3.8 R-stack]" cr

variable ok  0 ok !
variable ko  0 ko !
: pass  1 ok +! ."  OK " ;
: fail  1 ko +! ."  FAIL " ;
: ?t ( n expected -- ) = if pass else fail then ;

: t8r  10 >r r@ r> + ;
." >r r@ r> " t8r 20 ?t cr
: t8r2  1 2 2>r 2r@ + 2r> drop + ;
." 2>r 2r>  " t8r2 4 ?t cr
." unloop   " : t8u 5 0 do i dup 2 = if unloop exit then drop loop ; t8u 2 ?t cr

cr ." [3.9 Boucles]" cr
: t9a 0 5 0 do i + loop ;
: t9b 0 10 0 do i + 2 +loop ;
: t9c 0 0 0 ?do 1+ loop ;
: t9d 0 3 0 ?do 1+ loop ;
: t9e 0 10 0 do i + i 3 = if leave then loop ;
: t9f 0 2 0 do 2 0 do j + loop loop ;
." do loop  " t9a 10 ?t cr
." +loop    " t9b 20 ?t cr
." ?do skip " t9c 0 ?t cr
." ?do run  " t9d 3 ?t cr
." leave    " t9e 6 ?t cr
." j        " t9f 2 ?t cr

cr ." Rstack+Boucles: OK:" ok @ . ." FAIL:" ko @ . cr
