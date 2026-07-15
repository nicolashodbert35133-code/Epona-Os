\ ============================================================
\ NOTEPAD_APP.FTH  —  Éditeur de texte pour le bureau Epona
\ ============================================================
\ Crée via : app: Notepad 150 40 350 300 notepad-draw notepad-key
\ ============================================================

512 constant NOTE-SZ
create note-buf NOTE-SZ allot
0 note-buf NOTE-SZ fill
variable note-len  0 note-len !
variable note-cx   0 note-cx !

variable _wx  variable _wy  variable _ww  variable _wh

: note-insert ( char -- )
  note-len @ NOTE-SZ 1- >= if drop exit then
  note-cx @
  note-len @ note-cx @ - 1+ 0 do
    note-buf note-len @ i - + c@
    note-buf note-len @ i - 1+ + c!
  loop
  note-cx @ note-buf + c!
  note-cx @ 1+ note-cx ! note-len @ 1+ note-len ! ;

: note-bs ( -- )
  note-cx @ 0= if exit then
  note-cx @ note-len @ note-cx @ - 0 do
    note-buf note-cx @ i + 1+ c@
    note-buf note-cx @ i + c!
  loop
  note-cx @ 1- note-cx ! note-len @ 1- note-len ! ;

\ ── Draw ( wx wy ww wh -- ) ──────────────────────────────────
: notepad-draw ( wx wy ww wh -- )
  _wh ! _ww ! _wy ! _wx !

  \ Fond blanc
  _wx @ _wy @ _ww @ _wh @ 0xFFFFFF fb:rect

  \ Texte caractère par caractère
  note-len @ 0 do
    note-buf i + c@
    dup 10 = if drop leave then
    i 8 / 8 * _wy @ 5 + +        \ y
    i 8 mod 8 * _wx @ 5 + +      \ x
    swap                          \ x y ch
    0x00CCFF fb:text
  loop

  \ Curseur
  note-len @ 0> if
    note-cx @ 8 / 8 * _wy @ 5 + +
    note-cx @ 8 mod 8 * _wx @ 5 + +
    95 0xFFFFFF fb:text
  then

  \ Compteur
  _wx @ 5 + _wh @ 8 - note-len @ 48 + 0x888888 fb:text ;

\ ── Handlers ──────────────────────────────────────────────────
: notepad-key ( char -- )
  dup 8 = if drop note-bs exit then
  dup 27 = if drop exit then
  dup 13 = if drop 10 note-insert exit then
  dup 32 >= over 126 <= and if note-insert exit then
  drop ;

: notepad-click ( x y -- ) 2drop ;
