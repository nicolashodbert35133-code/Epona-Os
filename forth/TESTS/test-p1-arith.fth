\ TEST-P1-ARITH.FTH — Section 3.1 Arithmetique
cr ." [3.1 Arithmetique]" cr

variable ok  0 ok !
variable ko  0 ko !
: pass  1 ok +! ."  OK " ;
: fail  1 ko +! ."  FAIL " ;
: ?t ( n expected -- ) = if pass else fail then ;

." +        " 3 4 + 7 ?t cr
." -        " 10 3 - 7 ?t cr
." *        " 6 7 * 42 ?t cr
." /        " 10 3 / 3 ?t cr
." / zero   " 10 0 / 0 ?t cr
." mod      " 10 3 mod 1 ?t cr
." /mod q   " 10 3 /mod nip 3 ?t cr
." /mod r   " 10 3 /mod drop 1 ?t cr
." 1+       " 5 1+ 6 ?t cr
." 1-       " 5 1- 4 ?t cr
." 2+       " 10 2+ 12 ?t cr
." 2-       " 10 2- 8 ?t cr
." 2*       " 5 2* 10 ?t cr
." 2/       " 10 2/ 5 ?t cr
." abs +    " 42 abs 42 ?t cr
." abs -    " -42 abs 42 ?t cr
." negate   " 7 negate -7 ?t cr
." min      " 3 7 min 3 ?t cr
." max      " 3 7 max 7 ?t cr
." */       " 1000 1000 3 */ 333333 ?t cr
." */mod    " 10 7 3 */mod nip 23 ?t cr
." m*       " 100 100 m* drop 10000 ?t cr
." s>d pos  " 42 s>d drop 42 ?t cr
." s>d neg  " -1 s>d drop -1 ?t cr
." 4*       " 10 4* 40 ?t cr
." 4/       " 40 4/ 10 ?t cr
." 8*       " 5 8* 40 ?t cr
." 8/       " 40 8/ 5 ?t cr
." ²        " 7 ² 49 ?t cr
." um*      " 100 100 um* drop 10000 ?t cr
." fm/mod   " 7 s>d 2 fm/mod nip 3 ?t cr
." sm/rem   " 7 s>d 2 sm/rem nip 3 ?t cr

cr ." Arith: OK:" ok @ . ." FAIL:" ko @ . cr
