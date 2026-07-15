\ DESKTOP.FTH - Exemple de bureau en Forth pour Epona OS 1.01
\ 
\ Usage depuis le shell:
\   sys:load DESKTOP.FTH
\   s" mon-bureau" fullscreen-mode
\
\ Pour quitter le mode plein ecran: ESC ou tapez fullscreen-off

\ === Couleurs ===
0x1A1A2E constant FOND
0x16213E constant BARRE
0x0F3460 constant ACCENT
0xE94560 constant ROUGE
0x00D2FF constant CYAN
0xFFFFFF constant BLANC
0x888888 constant GRIS

\ === Dimensions ecran ===
variable SCR-W
variable SCR-H

\ === Ticks (animation) ===
variable TICK

\ === Dessine la barre du bas ===
: barre-bas ( -- )
    \ fond barre
    0 SCR-H @ 30 - SCR-W @ 30 BARRE rect
    \ separateur
    0 SCR-H @ 31 - SCR-W @ 1 ACCENT rect
    \ texte
    10 SCR-H @ 20 - s" Epona OS 1.01" BLANC 1 fb-text
;

\ === Formatage et affichage d'un entier ===
variable num-buf 16 allot

: draw-num ( n x y -- )
    >r >r
    dup 0= if
        drop
        [char] 0 num-buf c!
        r> r> num-buf 1 BLANC 1 fb-text
    else
        num-buf 15 +
        swap
        0 >r
        begin
            dup 0 >
        while
            10 /mod
            [char] 0 +
            rot 1-
            dup >r
            c!
            r>
            swap
            r> 1+ >r
        repeat
        drop
        r>
        r> r> 2swap
        BLANC 1 fb-text
    then
;

\ === Dessine une fenetre simple ===
: fenetre ( x y w h addr len -- )
    >r >r
    \ Pile: x y w h
    \ 1. Ombre
    2over
    swap 3 + swap 3 +
    2over
    0x333333 rect
    \ Pile: x y w h
    \ 2. Fond
    2over 2over
    0x252545 rect
    \ Pile: x y w h
    \ 3. Barre de titre
    2over 2over
    drop 22 ACCENT rect
    \ Pile: x y w h
    \ 4. Titre
    2drop
    swap 6 + swap 6 +
    r> r>
    BLANC 1 fb-text
;

\ === Icone texte ===
: icone ( x y addr len -- )
    >r >r
    2dup
    48 48 0x333355 rect
    2dup 48 48 0x0F3460 rect-outline
    swap 4 + swap 50 +
    r> r>
    BLANC 1 fb-text
;

\ === Dessin principal du bureau ===
: mon-bureau ( x y w h -- )
    drop drop drop drop    \ on ignore les args, on utilise SCR-W/SCR-H

    \ Fond ecran degrade
    0 0 SCR-W @ SCR-H @ FOND rect

    \ Quelques nuances pour le fond (grille subtile)
    SCR-H @ 20 do
        0 i SCR-W @ 1 0x1E1E3E rect
    80 +loop

    \ Titre principal
    SCR-W @ 2 / 120 - 80 s" Epona OS 1.01" CYAN 2 fb-text
    SCR-W @ 2 / 130 - 104 s" EponaForth Shell" GRIS 1 fb-text

    \ Icones
    80 200 s" Terminal" icone
    80 280 s" Editeur"  icone
    80 360 s" Fichiers" icone

    \ Fenetre exemple
    200 150 420 200 s" Console EponaForth" fenetre
    210 200 s" Bienvenue dans Epona OS 1.01" BLANC 1 fb-text
    210 215 s" Tapez 'words' pour les primitives" GRIS 1 fb-text
    210 230 s" ESC = retour bureau" ROUGE 1 fb-text

    \ Barre du bas
    barre-bas

    \ Heure (ticks en secondes)
    0 0 100 20 0x000000 rect   \ fond heure
    TICK @ 1000 / SCR-W @ 60 - SCR-H @ 18 - draw-num

    \ Incrementer tick
    1 TICK +!

    \ Swap buffers (afficher)
    fb-swap
;

\ Redimensionner le canvas a la taille de l'ecran
fb-size SCR-H ! SCR-W !
fb-size canvas-resize

cr .\" DESKTOP.FTH charge." cr
cr .\" Lancez: s\" mon-bureau\" fullscreen-mode" cr
cr .\" Pour quitter: ESC ou fullscreen-off" cr
