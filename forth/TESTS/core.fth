\ TESTS/core.fth - Tests de la bibliotheque pure forth/std/core.fth (Jour 57)
\ Valeurs attendues en commentaire. Mot : test-core (auto-execute en fin de fichier).
\ Prerequis : forth/std/core.fth charge (automatique au boot, drv_ensure_stdlib).
\   Ou manuellement : exec forth/std/core.fth
\ Aucun acces materiel : tout est testable sans peripherique.

\ Buffer de test pour upper/lower (top-level : `create` est un mot state 0)
create S1 8 allot

\ ============================================================================
\ MATH
\ ============================================================================
: test-math
  \ --- clamp ( n lo hi -- n' ) ---
  5 0 10 clamp .     \ 5
  -3 0 10 clamp .    \ 0
  42 0 10 clamp .    \ 10
  -5 -5 5 clamp .    \ -5
  7 0 7 clamp .      \ 7
  7 7 10 clamp .     \ 7

  \ --- between? ( n lo hi -- flag ) ---
  5 0 10 between? .  \ -1
  0 0 10 between? .  \ -1
  10 0 10 between? . \ -1
  11 0 10 between? . \ 0
  -1 0 10 between? . \ 0

  \ --- even? / odd? ---
  0 even? .          \ -1
  2 even? .          \ -1
  3 even? .          \ 0
  -4 even? .         \ -1
  1 odd? .           \ -1
  4 odd? .           \ 0

  \ --- sgn ( n -- -1|0|1 ) ---
  0 sgn .            \ 0
  5 sgn .            \ 1
  -5 sgn .           \ -1

  \ --- gcd ( a b -- g ) ---
  12 8 gcd .         \ 4
  17 5 gcd .         \ 1
  0 7 gcd .          \ 7
  100 25 gcd .       \ 25

  \ --- lcm ( a b -- l ) ---
  4 6 lcm .          \ 12
  3 5 lcm .          \ 15
  0 7 lcm .          \ 0

  \ --- pow ( base exp -- result ) ---
  2 0 pow .          \ 1
  2 3 pow .          \ 8
  3 4 pow .          \ 81
  5 1 pow .          \ 5
;

\ ============================================================================
\ CHAINES  ( paires addr len, un octet par cellule )
\ ============================================================================
: test-strings
  \ --- starts-with ---
  s" hello" s" hel" starts-with .  \ -1
  s" hello" s" x" starts-with .    \ 0
  s" hello" s" hello" starts-with . \ -1
  s" a" s" ab" starts-with .       \ 0

  \ --- ends-with ---
  s" hello" s" lo" ends-with .     \ -1
  s" hello" s" x" ends-with .      \ 0
  s" hello" s" hello" ends-with .  \ -1
  s" ab" s" b" ends-with .         \ -1
  s" ab" s" a" ends-with .         \ 0

  \ --- str-find ---
  s" bonjour" s" jour" str-find .  \ 3
  s" bonjour" s" on" str-find .    \ 1
  s" abc" s" x" str-find .         \ -1
  s" abc" s"" str-find .           \ 0

  \ --- count-char ---
  s" hello" 108 count-char .       \ 2   (l)
  s" hello" 111 count-char .       \ 1   (o)
  s" hello" 120 count-char .       \ 0   (x)

  \ --- upper / lower (en place) ---
  s" Hello" 8 S1 swap cmove
  S1 5 upper
  S1 5 type cr ." <- HELLO attendu" cr
  s" Hello" 8 S1 swap cmove
  S1 5 lower
  S1 5 type cr ." <- hello attendu" cr

  \ --- trim ---
  s"   bonjour   " trim ." [" type ." ]" cr ." <- [bonjour] attendu" cr
  s"   " trim ." [" type ." ]" cr ." <- [] attendu" cr
  s"bonjour" trim ." [" type ." ]" cr ." <- [bonjour] attendu" cr
;

\ ============================================================================
\ NOMBRES
\ ============================================================================
: test-numbers
  \ --- str>num ( addr len -- n ok ) ---
  s" 123" str>num . .   \ 123 -1
  s" -45" str>num . .   \ -45 -1
  s" 0" str>num . .     \ 0 -1
  s" 12a" str>num . .   \ 12 0
  s" " str>num . .      \ 0 0
  s" abc" str>num . .   \ 0 0

  \ --- num>str ( n -- addr len ) ---
  123 num>str type cr    \ 123
  -45 num>str type cr    \ -45
  0 num>str type cr      \ 0
  987654321 num>str type cr  \ 987654321
  -1 num>str type cr     \ -1
;

: test-core
  cr ." --- MATHS ---" cr
  test-math
  cr ." --- CHAINES ---" cr
  test-strings
  cr ." --- NOMBRES ---" cr
  test-numbers
  cr ." [CORE] tests termines" cr
;
test-core
