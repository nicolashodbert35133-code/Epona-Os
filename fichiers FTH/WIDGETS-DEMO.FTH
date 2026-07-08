\ WIDGETS-DEMO.FTH - Demonstration des widgets (boutons, champs, listes)
\ Execute:  sys:load WIDGETS-DEMO.FTH

\ Nettoyer les widgets precedents
widgets-clear

\ ─── Callback du bouton ───────────────────────────────────────
\ Execute quand on clique sur le bouton

: dire-bonjour ( -- )
    cr ." Bonjour depuis le callback Forth !" cr
;

\ ─── Initialisation compilee avec button-push ──────────────────
\ button-push lit le label entre "" et le mot de callback optionnel
\ depuis le flux de tokens, compile Op::ButtonPush.
\ Au runtime : ( x y w h -- ) cree le widget.

: init-widgets ( -- )
    \ button-push "Label" [callback]   -- compile, execute au runtime
    10 10  120 30  button-push "Cliquez ici" dire-bonjour
    10 50  200 24  textfield:
    10 80  200 120 list:
;

init-widgets

\ Remplir la liste avec s" ..." list-add
s" Element 1" list-add
s" Element 2" list-add
s" Element 3" list-add
s" Element 4" list-add
s" Element 5" list-add

\ ─── Mot de dessin ────────────────────────────────────────────
\ Appele par le systeme avec ( wx wy ww wh ) sur la pile

: demo-draw ( wx wy ww wh -- )
    2drop 2drop
    widgets-draw
;

\ ─── Mot clavier ──────────────────────────────────────────────
\ Appele avec ( n ) : n < 256 = caractere, n >= 256 = scancode+256

: demo-key ( n -- )
    drop
;

\ ─── Creer la fenetre ─────────────────────────────────────────
\ app: compile Op::AppCreate, execute au runtime avec ( x y w h )

: create-demo
    40 40 300 240 app: demo
;

create-demo

cr ." Fenetre 'demo' creee !" cr
cr ." Cliquez sur le bouton pour tester le callback." cr
