\ TEST-P1-COMP.FTH — Section 3.3 Comparaisons
cr ." [3.3 Comparaisons]" cr

variable ok  0 ok !
variable ko  0 ko !
: pass  1 ok +! ."  OK " ;
: fail  1 ko +! ."  FAIL " ;
: ?t ( n expected -- ) = if pass else fail then ;

." =  t     " 3 3 = -1 ?t cr
." =  f     " 3 4 = 0 ?t cr
." <> t     " 3 4 <> -1 ?t cr
." <> f     " 3 3 <> 0 ?t cr
." <  t     " 3 5 < -1 ?t cr
." <  f     " 5 3 < 0 ?t cr
." >  t     " 5 3 > -1 ?t cr
." >  f     " 3 5 > 0 ?t cr
." <= t     " 3 3 <= -1 ?t cr
." <= f     " 5 3 <= 0 ?t cr
." >= t     " 3 3 >= -1 ?t cr
." >= f     " 3 5 >= 0 ?t cr
." 0= t     " 0 0= -1 ?t cr
." 0= f     " 5 0= 0 ?t cr
." 0<> t    " 5 0<> -1 ?t cr
." 0<> f    " 0 0<> 0 ?t cr
." 0< t     " -3 0< -1 ?t cr
." 0< f     " 3 0< 0 ?t cr
." 0> t     " 5 0> -1 ?t cr
." 0> f     " -5 0> 0 ?t cr
." u< t     " 1 -1 u< -1 ?t cr
." u< f     " -1 1 u< 0 ?t cr
." u>       " -1 1 u> -1 ?t cr
." within t " 5 3 8 within -1 ?t cr
." within f " 8 3 8 within 0 ?t cr

cr ." Comparaisons: OK:" ok @ . ." FAIL:" ko @ . cr
