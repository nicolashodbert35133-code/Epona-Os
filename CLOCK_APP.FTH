\ ============================================================
\ CLOCK_APP.FTH  --  Horloge pour le bureau Epona
\ ============================================================
\ Cree via : app: Clock 10 40 120 120 clock-draw clock-key
\ ============================================================

variable clk-h
variable clk-m
variable clk-s
variable _cx
variable _cy
variable _hx
variable _hy

: digit>char ( n -- char ) 48 + ;

: draw-2dig ( x y val color -- )
  >r 10 /mod swap digit>char swap r>
  3 pick 8 + 3 pick 4 pick fb:text
  3 pick fb:text drop drop drop drop ;

: draw-colon ( x y color -- )
  >r 2dup 3 + 10 + r@ fb:text
  2dup 3 + 20 + r@ fb:text r> 2drop drop ;

\ Positions des 12 heures pour radius=25
variable _hdx
variable _hdy

: set-hpos ( dx dy -- ) _hdy ! _hdx ! ;

: h-pos ( h -- )
  dup  0 = if  0 -25 set-hpos exit then
  dup  1 = if 12 -22 set-hpos exit then
  dup  2 = if 21 -12 set-hpos exit then
  dup  3 = if 25   0 set-hpos exit then
  dup  4 = if 21  12 set-hpos exit then
  dup  5 = if 12  22 set-hpos exit then
  dup  6 = if  0  25 set-hpos exit then
  dup  7 = if -12 22 set-hpos exit then
  dup  8 = if -21 12 set-hpos exit then
  dup  9 = if -25  0 set-hpos exit then
  dup 10 = if -21 -12 set-hpos exit then
  dup 11 = if -12 -22 set-hpos exit then
  drop 0 0 set-hpos ;

\ Ligne depuis le centre vers (cx+dx, cy+dy)
\ Les offsets dx/dy sont dans _hx, _hy
: draw-hand ( color -- )
  >r
  _cx @ _cy @
  _hx @ _cx @ +
  _hy @ _cy @ +
  r>
  fb:line ;

: clock-draw ( wx wy ww wh -- )
  \ Fond noir
  4 pick 4 pick 3 pick 3 pick BLACK fb:rect

  \ Centre
  3 pick 3 pick + 2/ _cx !
  2 pick 2 pick + 2/ _cy !

  \ 12 marques du cadran
  12 0 do
    i h-pos
    _cx @ _hdx @ +
    _cy @ _hdy @ +
    FG fb:pixel
  loop

  \ Cercle approxime (lignes entre marques)
  12 0 do
    i h-pos
    _cx @ _hdx @ +
    _cy @ _hdy @ +
    i 1+ 12 mod h-pos
    _cx @ _hdx @ +
    _cy @ _hdy @ +
    FG fb:line
  loop

  \ Aiguille Heure (courte, blanche)
  clk-h @ 12 mod h-pos
  _hdx @ 2/ _hx !
  _hdy @ 2/ _hy !
  FG draw-hand

  \ Aiguille Minute (longue, cyan)
  clk-m @ 12 mod h-pos
  _hdx @ _hx !
  _hdy @ _hy !
  CYAN draw-hand

  \ Centre rouge
  _cx @ 1 - _cy @ 1 - 3 3 RED fb:rect

  \ Digits
  3 pick 10 + 3 pick 55 + clk-h @ FG draw-2dig
  3 pick 26 + 3 pick 55 + FG draw-colon
  3 pick 30 + 3 pick 55 + clk-m @ FG draw-2dig
  3 pick 46 + 3 pick 55 + FG draw-colon
  3 pick 50 + 3 pick 55 + clk-s @ FG draw-2dig

  drop drop drop drop ;

: clock-update ( -- )
  get-time >r >r >r
  clk-s ! clk-m ! clk-h !
  r> r> r> drop drop drop ;

: clock-click ( x y -- ) 2drop ;
: clock-key ( char -- ) drop ;
