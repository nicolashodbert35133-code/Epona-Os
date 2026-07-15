\ CANVAS_DEMO.FTH — Démo Canvas EponaForth
\ Canvas 400x300 : formes, lignes, animation
\ Tapez 'demo' pour lancer, ECHAP pour quitter

400 constant W
300 constant H

\ ── État ─────────────────────────────────────────────────────
variable bx  variable by
variable dx  variable dy
variable running

\ ── Couleurs ─────────────────────────────────────────────────
20 20 40 couleur  constant c-bg
255 255 255 couleur constant c-blanc
255 50 50 couleur  constant c-rouge
50 255 50 couleur  constant c-vert
50 50 255 couleur  constant c-bleu
255 255 50 couleur constant c-jaune
50 255 255 couleur constant c-cyan
255 50 255 couleur constant c-magenta
255 165 0 couleur  constant c-orange

\ ── Init balle ───────────────────────────────────────────────
: balle-init ( -- )
  100 bx !  50 by !  3 dx !  2 dy !  1 running ! ;

: balle-tick ( -- )
  bx @ dx + bx !  by @ dy + by !
  bx @ W 10 - >= if -1 dx ! then
  bx @ 10 <= if 1 dx ! then
  by @ H 10 - >= if -1 dy ! then
  by @ 10 <= if 1 dy ! then ;

\ ── Fond statique ────────────────────────────────────────────
: draw-bg ( -- )
  c-bg effacer

  \ Grille 4x3 de blocs colorés  ( x y w h color rect )
  20  50  80 50 c-rouge   rect
  120 50  80 50 c-vert    rect
  220 50  80 50 c-bleu    rect
  320 50  60 50 c-orange  rect

  20  120 80 50 c-cyan    rect
  120 120 80 50 c-magenta rect
  220 120 80 50 c-jaune   rect
  320 120 60 50 c-blanc   rect

  20  190 80 50 c-vert    rect
  120 190 80 50 c-rouge   rect
  220 190 80 50 c-bleu    rect
  320 190 60 50 c-cyan    rect

  \ Croix diagonale
  0 0  W H  c-cyan    ligne
  W 0  0 H  c-magenta ligne

  \ Lignes horizontales
  0 25  W 25   c-blanc ligne
  0 150 W 150  c-jaune ligne
  0 275 W 275  c-blanc ligne

  \ Triangle
  200 30  80 240  c-vert ligne
  80 240  320 240 c-vert ligne
  320 240 200 30  c-vert ligne

  \ Rectangle creux central
  140 100 120 100  c-bleu rect
  148 108 104  84  c-bg   rect
  140 100 120   4  c-cyan rect
  140 196 120   4  c-cyan rect
  140 100   4 100  c-cyan rect
  256 100   4 100  c-cyan rect ;

\ ── Boucle animée ────────────────────────────────────────────
: demo-loop ( -- )
  balle-init
  begin
    touche? dup 0<> if
      27 = if 0 running ! then
    else drop then
    balle-tick
    draw-bg
    bx @ by @ 10 10 c-jaune rect
    bx @ 3 + by @ 3 + 8 8 0x222222 rect
    30 ms
    running @ 0=
  until
  c-bg effacer
  cr ." Demo terminee !" cr ;

\ ── Point d'entrée ───────────────────────────────────────────
: demo ( -- )
  cr ." === CANVAS DEMO ===" cr
  ." Animation : balle rebondissante" cr
  ." ECHAP = quitter" cr
  demo-loop ;

: demo-static ( -- )
  draw-bg
  cr ." Formes dessinees sur le canvas" cr ;

: principal demo ;
