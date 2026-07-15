\ ============================================================
\ CALC_APP.FTH  —  Calculatrice pour le bureau Epona
\ ============================================================
\ Crée via : app: Calc 420 300 180 220 calc-draw calc-key
\ Utilise les widgets (boutons).
\ ============================================================

variable _cx  variable _cy  variable _cw  variable _ch
variable calc-val   0 calc-val !
variable calc-op    0 calc-op !
variable calc-acc   0 calc-acc !
variable calc-new   1 calc-new !

\ ── Helpers ───────────────────────────────────────────────────
: calc-op>char ( op -- char )
  dup 1 = if drop 43 exit then   \ '+'
  dup 2 = if drop 45 exit then   \ '-'
  dup 3 = if drop 42 exit then   \ '*'
  dup 4 = if drop 47 exit then   \ '/'
  drop 63 ;                      \ '?'

\ ── Draw ( wx wy ww wh -- ) ──────────────────────────────────
: calc-draw ( wx wy ww wh -- )
  _ch ! _cw ! _cy ! _cx !
  widgets-clear

  \ Fond
  _cx @ _cy @ _cw @ _ch @ 0x222222 fb:rect

  \ Affichage
  _cx @ 5 + _cy @ 5 + _cw @ 10 - 25 0xFFFFFF fb:rect
  _cx @ 8 + _cy @ 10 + calc-val @ 48 + 0x222222 fb:text
  calc-op @ 0> if
    _cx @ _cw @ 15 - _cy @ 10 + calc-op @ calc-op>char 0x888888 fb:text
  then

  \ Boutons grille 4×4
  4 0 do
    4 0 do
      j 40 * _cx @ 5 + +    \ bx
      i 30 * _cy @ 35 + +   \ by
      38 28
      button-push "btn" drop
    loop
  loop

  widgets-draw
  drop drop drop drop ;

\ ── Handlers ──────────────────────────────────────────────────
: calc-key ( char -- )
  dup 48 >= over 57 <= and if
    calc-new @ if
      0 calc-val !
      0 calc-new !
    then
    calc-val @ 10 * + 48 - calc-val !
  then
  dup 43 = if calc-val ! 1 calc-op ! 0 calc-val ! 1 calc-new ! then
  dup 45 = if calc-val ! 2 calc-op ! 0 calc-val ! 1 calc-new ! then
  dup 42 = if calc-val ! 3 calc-op ! 0 calc-val ! 1 calc-new ! then
  dup 47 = if calc-val ! 4 calc-op ! 0 calc-val ! 1 calc-new ! then
  dup 61 = if
    calc-op @ 1 = if calc-acc @ calc-val @ + calc-val ! then
    calc-op @ 2 = if calc-acc @ calc-val @ - calc-val ! then
    calc-op @ 3 = if calc-acc @ calc-val @ * calc-val ! then
    calc-op @ 4 = if
      calc-val @ 0<> if calc-acc @ calc-val @ / calc-val ! then
    then
    0 calc-op ! 1 calc-new !
  then
  dup 67 = if drop 0 calc-val ! 0 calc-op ! 0 calc-acc ! 1 calc-new ! then
  drop ;

: calc-click ( x y -- ) 2drop ;
