\ ─────────────────────────────────────────────────────────────
\  TESTS — Mathématiques supplémentaires (950-979) — §5.1
\  Sorties : `\ -1` = test OK, `\ 0` = échec
\ ─────────────────────────────────────────────────────────────

\ f2*   ( f -- 2f )
3.0 f2* 6.0 f= .   \ -1

\ f2/   ( f -- f/2 )
7.0 f2/ 3.5 f= .   \ -1

\ f**2  ( f -- f² )
4.0 f**2 16.0 f= .   \ -1
-3.0 f**2 9.0 f= .   \ -1

\ fsinπ ( f -- sin(f·π) )
0.0 fsinπ fz? .   \ -1
0.5 fsinπ 1.0 f- fabs 1e-9 f< .   \ -1

\ fcosπ ( f -- cos(f·π) )
0.0 fcosπ 1.0 f= .   \ -1
1.0 fcosπ 1.0 f+ fabs 1e-9 f< .   \ -1

\ fsincos ( f -- s c )  — c en haut de pile
0.0 fsincos f. f.   \ 1 0  (cos puis sin)

\ fatan ( f -- a )
1.0 fatan fpi2 f2/ f- fabs 1e-9 f< .   \ -1  (atan(1)=π/4)

\ fpow10 ( f -- 10^f )
2.0 fpow10 100.0 f- fabs 1e-9 f< .   \ -1

\ flog10 ( f -- log10(f) )
100.0 flog10 fround f>i 2 = .   \ -1

\ ffract ( f -- frac(f) )
3.7 ffract 1.0 f< .   \ -1
3.7 ffract f>i 0 = .   \ -1
-3.7 ffract f>i 0 = .   \ -1

\ fmod ( a b -- a mod b )
7.0 3.0 fmod 1.0 f= .   \ -1
-7.0 3.0 fmod -1.0 f= .   \ -1
7.0 0.0 fmod fnan? .   \ -1

\ fnan? ( f -- ? )
0.0 0.0 f/ fnan? .   \ -1
1.0 fnan? .   \ 0

\ finf? ( f -- ? )
1.0 0.0 f/ finf? .   \ -1
1.0 finf? .   \ 0

\ fz? ( f -- ? )
0.0 fz? .   \ -1
1.0 fz? .   \ 0

\ fmin+ ( f -- f' ) — flush à zéro positif
-0.0 fmin+ fz? .   \ -1
1e-310 fmin+ fz? .   \ -1
0.1 fmin+ 0.1 f= .   \ -1

\ f>bits / bits>f ( round-trip )
3.5 f>bits bits>f 3.5 f= .   \ -1

\ vec2+ ( ax ay bx by -- cx cy )
1.0 2.0 10.0 20.0 vec2+ f. f.   \ 22 11

\ vec2. ( x y -- l )
3.0 4.0 vec2. 5.0 f= .   \ -1

\ vec2* ( x y s -- x' y' )
3.0 4.0 2.0 vec2* f. f.   \ 8 6

\ mat2:identity ( addr -- )
variable M2
here M2 !
M2 @ mat2:identity
M2 @ f@ 1.0 f= .   \ -1
M2 @ 1 + f@ fz? .   \ -1
M2 @ 2 + f@ fz? .   \ -1
M2 @ 3 + f@ 1.0 f= .   \ -1

\ fclamp ( f lo hi -- f' )
5.0 0.0 10.0 fclamp 5.0 f= .   \ -1
-2.0 0.0 10.0 fclamp fz? .   \ -1
42.0 0.0 10.0 fclamp 10.0 f= .   \ -1

\ flerp ( a b t -- r )
0.0 10.0 0.5 flerp 5.0 f= .   \ -1
0.0 10.0 0.0 flerp fz? .   \ -1
0.0 10.0 1.0 flerp 10.0 f= .   \ -1

\ fsmooth ( t -- s )  smoothstep
0.5 fsmooth 0.5 f= .   \ -1
0.0 fsmooth fz? .   \ -1
1.0 fsmooth 1.0 f= .   \ -1

\ fdeg>rad / frad>deg
180.0 fdeg>rad fpi f- fabs 1e-9 f< .   \ -1
fpi frad>deg 180.0 f- fabs 1e-9 f< .   \ -1

\ fpi2 ( -- π/2 )
fpi2 fpi f2/ f- fabs 1e-9 f< .   \ -1

\ frand ( -- f ) dans [0,1)
variable RAND-TMP
frand RAND-TMP !
RAND-TMP @ 0.0 f>= .   \ -1
RAND-TMP @ 1.0 f< .   \ -1

\ frand2 ( lo hi -- f ) dans [lo,hi)
2.0 5.0 frand2 RAND-TMP !
RAND-TMP @ 2.0 f>= .   \ -1
RAND-TMP @ 5.0 f< .   \ -1
