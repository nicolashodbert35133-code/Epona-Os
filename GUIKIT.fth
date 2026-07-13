\ GUIKIT.FTH

: ui:window ( x y w h title -- )
  \ Fenêtre avec barre de titre
  2over 2over 0x2C3E50 rect          \ fond
  2over swap drop over 20 0x1A252F rect  \ barre titre
  2over 5 + swap 5 + swap 10 0xECF0F1 gpu:text
;

: ui:button ( x y w h label -- pressed? )
  \ Bouton avec état hover
  souris >r >r
  2over 2over
  r@ r> \ x y btn
  \ Vérifier hover
  3 pick over >= 5 pick over >= and
  4 pick over 5 pick + <= and
  3 pick over 4 pick + <= and
  swap drop
  if
    r@ 1 = if 0x2980B9 else 0x3498DB then
  else
    0x2C3E50
  then
  r> drop
  rect
  \ Label centré
  \ ...
  0  \ non pressé pour l'instant
;