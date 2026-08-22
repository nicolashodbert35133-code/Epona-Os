\ ============================================================
\ TEST-P1.FTH — Primitives fondamentales (sections 3.1 a 3.12)
\ Epona OS 1.98
\ ============================================================
cr cr ." ======== PARTIE 1/3 : FONDAMENTAUX ========" cr

variable ok  0 ok !
variable ko  0 ko !
: pass  1 ok +! ."  OK " ;
: fail  1 ko +! ."  FAIL " ;
: ?t ( n expected -- ) = if pass else fail then ;

\ ---- 3.1 ARITHMETIQUE ----
cr ." [3.1 Arithmetique]" cr
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

\ ---- 3.2 PILE ----
cr ." [3.2 Pile]" cr
." dup      " 42 dup 42 = swap 42 = and -1 = pass drop cr
." drop     " 1 2 drop 1 ?t cr
." swap     " 1 2 swap 1 ?t cr
." over     " 1 2 over 1 ?t nip nip cr
." rot      " 1 2 3 rot 1 ?t nip nip cr
." -rot     " 1 2 3 -rot 2 ?t nip nip cr
." nip      " 1 2 nip 2 ?t cr
." tuck     " 1 2 tuck nip nip 2 ?t cr
." 2dup     " 3 4 2dup 4 ?t nip nip nip cr
." 2drop    " 1 2 3 4 2drop 2 ?t drop cr
." 2swap    " 1 2 3 4 2swap 2 ?t nip nip cr
." 2over    " 1 2 3 4 2over 2 ?t 2drop 2drop drop cr
." ?dup nz  " 5 ?dup 5 ?t drop cr
." ?dup z   " 0 ?dup 0 ?t cr
." pick     " 10 20 30 1 pick 20 ?t 2drop drop cr
." depth    " 1 2 3 depth 3 ?t drop drop drop cr
." roll     " 10 20 30 40 2 roll 20 ?t drop drop drop cr
." .s       " 1 2 .s 2drop cr
." pile     " 10 20 pile 2drop cr

\ ---- 3.3 COMPARAISONS ----
cr ." [3.3 Comparaisons]" cr
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

\ ---- 3.4 LOGIQUE ----
cr ." [3.4 Logique]" cr
." and      " 255 15 and 15 ?t cr
." or       " 240 15 or 255 ?t cr
." xor      " 255 15 xor 240 ?t cr
." invert   " 0 invert -1 ?t cr
." lshift   " 1 8 lshift 256 ?t cr
." rshift   " 256 4 rshift 16 ?t cr

\ ---- 3.5 MEMOIRE CELLULAIRE ----
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

\ ---- 3.6 MEMOIRE OCTETS ----
cr ." [3.6 Octets]" cr
variable t6m
." c! c@    " 65 t6m c! t6m c@ 65 ?t cr
." w! w@    " 12345 t6m w! t6m w@ 12345 ?t cr
." l! l@    " 100000 t6m l! t6m l@ 100000 ?t cr

\ ---- 3.7 MEMOIRE BLOC ----
cr ." [3.7 Bloc]" cr
." fill     " here 10 42 fill here @ 42 ?t cr
." erase    " here 10 erase here @ 0 ?t cr
." blank    " pad 10 blank pad @ 32 ?t cr
." cmove    " here 5 99 fill  here here 5 + 5 cmove  here 5 + @ 99 ?t cr
." move     " here 5 88 fill  here here 10 + 5 move  here 10 + @ 88 ?t cr

\ ---- 3.8 R-STACK ----
cr ." [3.8 R-stack]" cr
: t8r  10 >r r@ r> + ;
." >r r@ r> " t8r 20 ?t cr
: t8r2  1 2 2>r 2r@ + 2r> drop + ;
." 2>r 2r>  " t8r2 6 ?t cr
." unloop   " : t8u 5 0 do i dup 2 = if unloop exit then drop loop ; t8u 2 ?t cr

\ ---- 3.9 BOUCLES ----
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

\ ---- 3.10 SORTIE ----
cr ." [3.10 Sortie]" cr
." .        " 42 . pass cr
." u.       " 255 u. pass cr
." cr       " pass cr
." space    " pass space cr
." spaces   " pass 3 spaces cr
." emit     " 65 emit pass cr
." type     " s" OK" type pass cr
." .r       " 42 8 .r pass cr
." u.r      " 255 8 u.r pass cr

\ ---- 3.11 PNO ----
cr ." [3.11 PNO]" cr
." <# # #s #> " 42 0 <# #s #> type pass cr
." hold     " 1234 0 <# # # 44 hold #s #> type pass cr
." sign     " -5 dup abs 0 <# #s rot sign #> type pass cr
." holds    " 42 0 <# s" eur" holds #s #> type pass cr

\ ---- 3.12 ENTREE ----
cr ." [3.12 Entree (non-bloquant)]" cr
." touche?  " touche? drop pass cr
." key?     " key? drop pass cr
." touche:inject " 65 touche:inject pass cr

cr cr ." -- P1 termine -- OK:" ok @ . ."  FAIL:" ko @ . cr