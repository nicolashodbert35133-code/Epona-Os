\ ============================================================================
\ TESTS/floats.fth - Primitives flottantes 900-944 (DEV_GUIDE_PRIMITIVES.md 5.1)
\ Usage (une fois le FS monté) : included TESTS/floats.fth
\ Ou : copier-coller dans le shell, puis taper  test-floats
\
\ Ce dialecte n'a pas de mot "assert" : chaque ligne AFFICHE le résultat,
\ la valeur attendue est indiquée en commentaire. Vérifier visuellement.
\ ============================================================================

create FTMP   \ cellule Forth pour tester f! / f@ (espace `here`)

: test-floats
    \ --- Arithmétique ------------------------------------------------------
    cr ." f+ : "        3.0 2.0 f+ f.           \ 5.000000
    cr ." f- : "        3.0 2.0 f- f.           \ 1.000000
    cr ." f* : "        3.0 2.0 f* f.           \ 6.000000
    cr ." f/ : "        3.0 2.0 f/ f.           \ 1.500000
    cr ." f/ par 0 : "  1.0 0.0 f/ f.           \ inf

    \ --- Comparaisons (flags -1 / 0) ----------------------------------------
    cr ." f< : "    1.0 2.0 f< .                \ -1
    cr ." f> : "    2.0 1.0 f> .                \ -1
    cr ." f= : "    2.0 2.0 f= .                \ -1
    cr ." f<= : "   2.0 2.0 f<= .               \ -1
    cr ." f>= : "   2.0 1.0 f>= .               \ -1
    cr ." f0= : "   0.0 f0= .                   \ -1
    cr ." f0< : "   -1.0 f0< .                  \ -1

    \ --- Transformations ------------------------------------------------------
    cr ." fnegate : "     3.5 fnegate f.        \ -3.500000
    cr ." fabs : "        -3.5 fabs f.          \ 3.500000
    cr ." fmin : "        2.0 3.0 fmin f.       \ 2.000000
    cr ." fmax : "        2.0 3.0 fmax f.       \ 3.000000
    cr ." fsqrt : "       2.0 fsqrt f.          \ 1.414214
    cr ." ffloor : "      2.7 ffloor f.         \ 2.000000
    cr ." fceil : "       2.7 fceil f.          \ 3.000000
    cr ." fround(2.5) : " 2.5 fround f.         \ 2.000000 (arrondi bancaire)

    \ --- Transcendantes (libm) ------------------------------------------------
    cr ." fsin(0) : "     0.0 fsin f.           \ 0.000000
    cr ." fcos(0) : "     0.0 fcos f.           \ 1.000000
    cr ." ftan(0) : "     0.0 ftan f.           \ 0.000000
    cr ." fatan2(1,1) : " 1.0 1.0 fatan2 f.     \ 0.785398
    cr ." fexp(1) : "     1.0 fexp f.           \ 2.718282
    cr ." fln(1) : "      1.0 fln f.            \ 0.000000
    cr ." flog2(8) : "    8.0 flog2 f.          \ 3.000000
    cr ." fpow(2,10) : "  2.0 10.0 fpow f.      \ 1024.000000
    cr ." fhypot(3,4) : " 3.0 4.0 fhypot f.     \ 5.000000
    cr ." fasin(1) : "    1.0 fasin f.          \ 1.570796
    cr ." facos(1) : "    1.0 facos f.          \ 0.000000

    \ --- Conversions -----------------------------------------------------------
    cr ." f>i(3.7) : "    3.7 f>i .             \ 3
    cr ." i>f(3) : "      3 i>f f.              \ 3.000000
    cr ." f>s/s>f : "     3.14 64 balloc dup f>s s>f f.   \ 3.140000

    \ --- Constantes ---------------------------------------------------------------
    cr ." fpi : "         fpi f.                \ 3.141593
    cr ." fe : "          fe f.                 \ 2.718282

    \ --- Précision ------------------------------------------------------------------
    cr ." f.prec(3) : "   3.14159 3 f.prec      \ 3.142

    \ --- Pile -----------------------------------------------------------------------
    cr ." fdup : "        3.0 fdup f+ f.        \ 6.000000
    cr ." fdrop : "       3.0 fdrop 2.0 f+ f.   \ 2.000000
    cr ." fswap : "       1.0 2.0 fswap f- f.   \ 1.000000
    cr ." fover : "       1.0 2.0 fover f- f.   \ 1.000000
    cr ." frot : "        1.0 2.0 3.0 frot f.   \ 1.000000

    \ --- Mémoire (memory[] via check_mem) ----------------------------------------
    cr ." f! f@ : "       3.14 FTMP f! FTMP f@ f.   \ 3.140000
;

test-floats
