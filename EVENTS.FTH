\ ============================================================
\ EVENTS.FTH  —  Système d'événements EponaForth
\ ============================================================
\ Utilise `defer` et `is` pour la liaison dynamique.
\ Dépendances : STDLIB.FTH
\ ============================================================

\ ─── Déclarations des événements ─────────────────────────────
defer on-key-press      \ ( char -- )
defer on-key-release    \ ( char -- )
defer on-mouse-move     \ ( x y -- )
defer on-mouse-click    \ ( x y btn -- )
defer on-mouse-wheel    \ ( delta -- )
defer on-tick           \ ( ms -- )
defer on-resize         \ ( w h -- )
defer on-quit           \ ( -- )
defer exit-requested?   \ ( -- flag ) vrai = quitter la boucle
: no-exit 0 ;
' no-exit is exit-requested?

\ ─── Handlers par défaut (no-op) ─────────────────────────────
: default-nop drop ;
: default-nop2 drop drop ;
: default-nop3 drop drop drop ;

' default-nop  is on-key-press
' default-nop  is on-key-release
' default-nop2 is on-mouse-move
' default-nop3 is on-mouse-click
' default-nop  is on-mouse-wheel
' default-nop  is on-tick
' default-nop2 is on-resize
' default-nop  is on-quit

\ ─── Stockage du dernier événement ───────────────────────────
variable last-key
variable last-mx
variable last-my
variable last-mb

\ ─── Boucle principale d'événements ──────────────────────────
: poll-keyboard ( -- )
  touche? dup if
    dup last-key !
    on-key-press
  else
    drop
  then
;

: poll-mouse ( -- )
  souris? if
    souris              \ ( -- x y btn )
    dup last-mb !       \ save btn. Stack: x y
    over last-mx !      \ save x. Stack: x y
    dup last-my !       \ save y. Stack: x y
    on-mouse-move       \ on-mouse-move( x y -- )
    last-mb @ if
      last-mx @ last-my @ last-mb @ on-mouse-click
    then
  then
;

: poll-tick ( -- )
  ticks on-tick
;

\ ─── Boucle événementielle ───────────────────────────────────
: event-loop ( -- )
  begin
    poll-keyboard
    poll-mouse
    poll-tick
    16 ms
    exit-requested? if
      on-quit
      1
    else
      0
    then
  until
;

\ ─── Exemple ─────────────────────────────────────────────────
cr ." EVENTS.FTH charge" cr
cr ." Exemple d'utilisation :" cr
cr ."  : my-key ( char -- ) .\" Touche: \" emit cr ;" cr
cr ."  ' my-key is on-key-press" cr
cr ."  event-loop" cr
