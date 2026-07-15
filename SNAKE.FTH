\ ════════════════════════════════════════════════════════════════════════
\                    SNAKE.FTH — Jeu Snake
\                     EponaForth — Epona OS
\ ════════════════════════════════════════════════════════════════════════
\
\ Dépendances :
\   require STDLIB.FTH
\   require EVENTS.FTH
\
\ Chargement :
\   sys:load SNAKE.FTH
\   snake
\
\ Contrôles :
\   Flèches ou ZQSD  — Diriger le serpent
\   P                — Pause
\   R                — Recommencer
\   Échap            — Quitter
\
\ ════════════════════════════════════════════════════════════════════════

require STDLIB.FTH
require EVENTS.FTH

\ ──────────────────────────────────────────────────────────────────────
\ 1. CONSTANTES
\ ──────────────────────────────────────────────────────────────────────

\ Dimensions de la grille
20 constant GRID-W          \ largeur en cellules
15 constant GRID-H          \ hauteur en cellules
16 constant CELL-SIZE       \ taille d'une cellule en pixels

\ Position de la grille dans le canvas (400x300)
20 constant GRID-OX         \ offset X du coin supérieur gauche
18 constant GRID-OY         \ offset Y du coin supérieur gauche

\ Taille maximale du serpent
300 constant SNAKE-MAX      \ GRID-W * GRID-H

\ Directions
0 constant DIR-UP
1 constant DIR-RIGHT
2 constant DIR-DOWN
3 constant DIR-LEFT

\ États du jeu
0 enum GAME-MENU
  enum GAME-PLAY
  enum GAME-PAUSE
  enum GAME-OVER
drop

\ Vitesses (ms entre chaque tick)
150 constant SPEED-SLOW
100 constant SPEED-NORMAL
70  constant SPEED-FAST
50  constant SPEED-TURBO

\ Couleurs
0x1A1A2E constant COL-BG          \ fond général (bleu nuit)
0x16213E constant COL-GRID-BG     \ fond de la grille
0x0F3460 constant COL-GRID-LINE   \ lignes de grille
0x4CAF50 constant COL-SNAKE-HEAD  \ tête du serpent (vert vif)
0x2E7D32 constant COL-SNAKE-BODY  \ corps du serpent (vert foncé)
0x81C784 constant COL-SNAKE-TAIL  \ queue (vert clair)
0xFF5252 constant COL-APPLE       \ pomme (rouge)
0xFFD740 constant COL-GOLD-APPLE  \ pomme dorée (bonus)
0xFFFFFF constant COL-TEXT        \ texte blanc
0xFFD740 constant COL-SCORE       \ score doré
0xFF5252 constant COL-GAMEOVER    \ game over rouge
0x424242 constant COL-BORDER      \ bordure

\ ──────────────────────────────────────────────────────────────────────
\ 2. ÉTAT DU JEU
\ ──────────────────────────────────────────────────────────────────────

\ Corps du serpent : tableau de (x, y) encodés comme x*100+y
create snake-x SNAKE-MAX allot   \ coordonnées X de chaque segment
create snake-y SNAKE-MAX allot   \ coordonnées Y de chaque segment

variable snake-len               \ longueur actuelle
variable snake-dir               \ direction courante
variable snake-next-dir          \ prochaine direction (buffering input)

variable apple-x                 \ position pomme normale
variable apple-y
variable gold-x                  \ position pomme dorée (-1 si absente)
variable gold-y
variable gold-timer              \ timer pomme dorée (disparaît après N ticks)

variable score                   \ score courant
variable best-score              \ meilleur score de la session
variable level                   \ niveau courant (vitesse)
variable game-state              \ état courant (GAME-MENU/PLAY/PAUSE/OVER)
variable tick-speed              \ millisecondes entre chaque tick
variable tick-count              \ compteur de ticks depuis le début
variable apples-eaten            \ nombre de pommes mangées

variable snake-growing           \ nombre de segments à ajouter encore
variable rng-seed                \ graine pour le générateur pseudo-aléatoire

\ ──────────────────────────────────────────────────────────────────────
\ 3. UTILITAIRES
\ ──────────────────────────────────────────────────────────────────────

: snake-rng ( -- n )
  \ Générateur LCG simple
  rng-seed @ 1664525 * 1013904223 + rng-seed !
  rng-seed @ abs ;

: snake-rand ( max -- n )
  \ Nombre pseudo-aléatoire 0..max-1
  dup 0= if drop 0 exit then
  snake-rng swap mod abs ;

: cell>pixel-x ( gx -- px )
  \ Convertit une coordonnée grille X en pixel canvas
  CELL-SIZE * GRID-OX + ;

: cell>pixel-y ( gy -- py )
  \ Convertit une coordonnée grille Y en pixel canvas
  CELL-SIZE * GRID-OY + ;

: snake-head-x ( -- gx )
  0 snake-x + @ ;

: snake-head-y ( -- gy )
  0 snake-y + @ ;

: snake-seg-x ( idx -- gx )
  snake-x + @ ;

: snake-seg-y ( idx -- gy )
  snake-y + @ ;

\ ──────────────────────────────────────────────────────────────────────
\ 4. INITIALISATION
\ ──────────────────────────────────────────────────────────────────────

: snake-on-body? ( gx gy -- flag )
  \ Vérifie si la position (gx,gy) est sur un segment du serpent
  0 >r
  snake-len @ 0 do
    over i snake-seg-x = if
      over i snake-seg-y = if
        r> drop 1 >r leave
      then
    then
  loop
  2drop r> ;

: snake-place-apple ( -- )
  \ Place la pomme à une position libre aléatoirement
  begin
    GRID-W snake-rand apple-x !
    GRID-H snake-rand apple-y !
    apple-x @ apple-y @ snake-on-body? 0=
  until ;

: snake-place-gold ( -- )
  \ Place une pomme dorée bonus à une position libre
  begin
    GRID-W snake-rand gold-x !
    GRID-H snake-rand gold-y !
    gold-x @ apple-x @ <> gold-y @ apple-y @ <> or
    gold-x @ gold-y @ snake-on-body? 0= and
  until
  30 gold-timer ! ;              \ disparaît après 30 ticks

: snake-init ( -- )
  \ Initialise ou réinitialise le jeu
  ticks rng-seed !              \ graine basée sur le temps

  \ Serpent initial : 3 segments au centre, dirigé vers la droite
  GRID-W 2/ 0 snake-x + !
  GRID-H 2/ 0 snake-y + !
  GRID-W 2/ 1- 1 snake-x + !
  GRID-H 2/ 1 snake-y + !
  GRID-W 2/ 2- 2 snake-x + !
  GRID-H 2/ 2 snake-y + !
  3 snake-len !

  DIR-RIGHT snake-dir !
  DIR-RIGHT snake-next-dir !

  0 score !
  0 tick-count !
  0 apples-eaten !
  0 snake-growing !
  1 level !
  SPEED-NORMAL tick-speed !

  -1 gold-x !                   \ pas de pomme dorée au départ
  -1 gold-y !
  0 gold-timer !

  snake-place-apple
  GAME-PLAY game-state ! ;

\ ──────────────────────────────────────────────────────────────────────
\ 5. LOGIQUE DE JEU
\ ──────────────────────────────────────────────────────────────────────

: snake-check-collision ( nx ny -- dead? )
  \ Vérifie si la tête va entrer en collision
  over 0 < over 0 < or                    \ bord gauche/haut
  2 pick GRID-W >= or                      \ bord droit
  2 pick GRID-H >= or if                   \ bord bas
    2drop 1 exit
  then
  \ Collision avec le corps (sauf le tout dernier segment)
  0 >r
  snake-len @ 1- 0 do
    over i snake-seg-x = if
      2 pick i snake-seg-y = if
        r> drop 1 >r leave
      then
    then
  loop
  2drop r> ;

: snake-move-body ( -- )
  \ Décale tous les segments d'un cran (queue → tête)
  snake-len @ 1- 0 do
    \ segment[i+1] devient segment[i]
    snake-len @ 1- i - 1-   \ index courant (de la queue à la tête)
    dup 1+ swap
    snake-seg-x over snake-x + !
    snake-seg-y swap snake-y + !
  loop ;

: snake-new-head ( -- nx ny )
  \ Calcule la nouvelle position de la tête
  snake-head-x snake-head-y
  snake-next-dir @ snake-dir !   \ appliquer la direction buffered
  snake-dir @ case
    DIR-UP    of swap 1-  swap endof
    DIR-DOWN  of swap 1+  swap endof
    DIR-LEFT  of 1-       endof
    DIR-RIGHT of 1+       endof
  endcase ;

: snake-eat-apple ( -- )
  \ Le serpent mange la pomme normale
  10 level @ * score +!         \ +10 points × niveau
  1 apples-eaten +!
  3 snake-growing +!            \ grandit de 3 segments
  snake-place-apple

  \ Tous les 5 pommes → augmenter le niveau
  apples-eaten @ 5 mod 0= if
    level @ 4 < if
      1 level +!
      level @ case
        2 of SPEED-FAST   tick-speed ! endof
        3 of SPEED-TURBO  tick-speed ! endof
        4 of 40           tick-speed ! endof
      endcase
    then
  then

  \ Apparition d'une pomme dorée tous les 7 pommes
  apples-eaten @ 7 mod 0= if
    gold-x @ -1 = if           \ pas déjà une pomme dorée
      snake-place-gold
    then
  then ;

: snake-eat-gold ( -- )
  \ Le serpent mange la pomme dorée
  50 level @ * score +!         \ +50 points × niveau
  5 snake-growing +!            \ grandit de 5 segments
  -1 gold-x !                   \ supprimer la pomme dorée
  -1 gold-y ! ;

: snake-tick ( -- )
  \ Un tick de jeu
  game-state @ GAME-PLAY <> if exit then

  1 tick-count +!

  \ Timer pomme dorée
  gold-timer @ 0 > if
    -1 gold-timer +!
    gold-timer @ 0= if
      -1 gold-x !               \ la pomme dorée disparaît
      -1 gold-y !
    then
  then

  \ Calculer la nouvelle position de la tête
  snake-new-head                \ -- nx ny

  \ Vérifier la collision
  2dup snake-check-collision if
    2drop
    GAME-OVER game-state !
    \ Mettre à jour le meilleur score
    score @ best-score @ > if
      score @ best-score !
    then
    exit
  then

  \ Déplacer le corps
  snake-growing @ 0 > if
    \ Ajouter un segment (grandir)
    -1 snake-growing +!
    1 snake-len +!
    \ Vérifier le max
    snake-len @ SNAKE-MAX >= if
      SNAKE-MAX snake-len !
    then
  then

  snake-move-body

  \ Placer la nouvelle tête
  over 0 snake-x + !
  dup  0 snake-y + !

  \ Vérifier si on mange la pomme
  snake-head-x apple-x @ = if
    snake-head-y apple-y @ = if
      snake-eat-apple
    then
  then

  \ Vérifier si on mange la pomme dorée
  gold-x @ -1 <> if
    snake-head-x gold-x @ = if
      snake-head-y gold-y @ = if
        snake-eat-gold
      then
    then
  then

  drop drop ;

\ ──────────────────────────────────────────────────────────────────────
\ 6. RENDU GRAPHIQUE
\ ──────────────────────────────────────────────────────────────────────

: draw-cell ( gx gy color -- )
  \ Dessine une cellule de la grille (avec un petit bord)
  >r
  cell>pixel-x cell>pixel-y
  CELL-SIZE 2 - CELL-SIZE 2 -
  r> rect ;

: draw-cell-rounded ( gx gy color -- )
  \ Dessine une cellule avec coins arrondis (simulé)
  draw-cell ;                   \ simplifié pour le moment

: draw-grid-bg ( -- )
  \ Fond de la grille
  GRID-OX GRID-OY
  GRID-W CELL-SIZE * GRID-H CELL-SIZE *
  COL-GRID-BG rect
  \ Bordure
  GRID-OX 2 - GRID-OY 2 -
  GRID-W CELL-SIZE * 4 + GRID-H CELL-SIZE * 4 +
  COL-BORDER rect
  GRID-OX GRID-OY
  GRID-W CELL-SIZE * GRID-H CELL-SIZE *
  COL-GRID-BG rect ;

: draw-snake ( -- )
  \ Dessine le serpent segment par segment
  snake-len @ 0 ?do
    i 0 = if
      \ Tête : vert vif
      i snake-seg-x i snake-seg-y COL-SNAKE-HEAD draw-cell
    else
      i snake-len @ 1- = if
        \ Queue : vert clair
        i snake-seg-x i snake-seg-y COL-SNAKE-TAIL draw-cell
      else
        \ Corps : vert foncé avec dégradé selon position
        \ Plus clair près de la tête, plus foncé près de la queue
        i snake-seg-x i snake-seg-y COL-SNAKE-BODY draw-cell
      then
    then
  loop ;

: draw-apples ( -- )
  \ Dessine la pomme normale
  apple-x @ apple-y @ COL-APPLE draw-cell
  \ Dessine la pomme dorée si présente
  gold-x @ -1 <> if
    \ Clignotement : afficher seulement si tick pair ou timer > 10
    gold-timer @ 10 > tick-count @ 2 mod 0= or if
      gold-x @ gold-y @ COL-GOLD-APPLE draw-cell
    then
  then ;

: draw-hud ( -- )
  \ HUD simplifié : score et niveau en blocs colorés
  0 0 400 16 COL-BG rect
  \ Barre score à gauche
  2 3 50 8 COL-SCORE rect
  \ Barres niveau à droite
  level @ 0 do
    380 i 8 * + 2 6 6 COL-SCORE rect
  loop ;

: draw-score-simple ( -- )
  \ Affichage score simplifié en pixels (chiffres pixelisés)
  \ Score en haut à gauche
  0 0 200 14 COL-BG rect

  \ Dessiner "SCORE" comme blocs colorés
  2 3 50 8 COL-SCORE rect       \ barre titre score

  \ Niveau en haut à droite
  300 0 100 14 COL-BG rect
  \ Barre de niveau (un bloc par niveau)
  level @ 0 do
    320 i 12 * + 2 10 10 COL-SNAKE-HEAD rect
  loop ;

: draw-game-over-screen ( -- )
  \ Écran Game Over
  \ Assombrir la grille
  GRID-OX GRID-OY
  GRID-W CELL-SIZE * GRID-H CELL-SIZE *
  0x000000 rect

  \ Rectangle central
  80 100 240 80 0x1A1A2E rect
  82 102 236 76 0x0F3460 rect

  \ Lignes de texte (simulées par des blocs colorés)
  \ Ligne "GAME OVER" — blocs rouges
  100 115 200 12 COL-GAMEOVER rect

  \ Ligne score — blocs dorés
  100 135 200 8 COL-SCORE rect

  \ Ligne "R = rejouer, Échap = quitter"
  90 158 220 6 0x808080 rect ;

: draw-menu-screen ( -- )
  \ Écran de menu
  0 0 400 300 COL-BG rect

  \ Titre : SNAKE — blocs verts
  50 40 300 30 COL-SNAKE-HEAD rect
  52 42 296 26 COL-BG rect
  \ Lettres S N A K E simulées par des blocs
  60  42 20 26 COL-SNAKE-HEAD rect
  100 42 20 26 COL-SNAKE-HEAD rect
  140 42 20 26 COL-SNAKE-HEAD rect
  180 42 20 26 COL-SNAKE-HEAD rect
  220 42 20 26 COL-SNAKE-HEAD rect

  \ Serpent décoratif
  20 0 do
    i 12 * 50 + 100 12 12 COL-SNAKE-BODY rect
  loop
  50 100 12 12 COL-SNAKE-HEAD rect

  \ Instructions
  100 140 200 2 0x444444 rect   \ ligne décorative
  80  160 20 10 COL-APPLE rect  \ icône pomme
  \ "Appuyez ESPACE pour commencer"
  110 158 180 10 0x666666 rect

  \ Contrôles
  80 190 240 8 0x444444 rect
  80 205 240 8 0x444444 rect
  80 220 240 8 0x444444 rect ;

: draw-pause-screen ( -- )
  \ Écran de pause (overlay semi-transparent)
  130 120 140 50 0x000033 rect
  132 122 136 46 0x0F3460 rect
  \ "PAUSE" en blocs
  145 135 110 8 COL-SCORE rect
  145 150 110 6 0x666666 rect ;

: snake-render ( -- )
  \ Rendu complet d'une frame
  game-state @ case

    GAME-MENU of
      draw-menu-screen
    endof

    GAME-PLAY of
      \ Fond
      0 0 400 300 COL-BG rect
      \ Grille
      draw-grid-bg
      \ Pommes
      draw-apples
      \ Serpent
      draw-snake
      \ HUD
      draw-score-simple
    endof

    GAME-PAUSE of
      \ Garder le jeu affiché en dessous
      draw-grid-bg
      draw-apples
      draw-snake
      draw-score-simple
      \ Overlay pause
      draw-pause-screen
    endof

    GAME-OVER of
      \ Afficher le dernier état du jeu
      draw-grid-bg
      draw-apples
      draw-snake
      draw-score-simple
      \ Écran game over par-dessus
      draw-game-over-screen
    endof

  endcase ;

\ ──────────────────────────────────────────────────────────────────────
\ 7. GESTION DES ENTRÉES
\ ──────────────────────────────────────────────────────────────────────

: snake-can-turn ( new-dir -- flag )
  \ Empêche le serpent de faire demi-tour
  snake-dir @
  case
    DIR-UP    of over DIR-DOWN  <> endof
    DIR-DOWN  of over DIR-UP    <> endof
    DIR-LEFT  of over DIR-RIGHT <> endof
    DIR-RIGHT of over DIR-LEFT  <> endof
    drop 1
  endcase
  nip ;

: snake-handle-key ( char -- )
  \ Gérer une touche selon l'état du jeu
  game-state @ case

    GAME-MENU of
      \ ESPACE ou ENTRÉE pour commencer
      dup 32 = over 13 = or if
        snake-init
      then
      drop
    endof

    GAME-PLAY of
      case
        \ Directions (ZQSD + flèches WASD)
        [char] z of
          DIR-UP snake-can-turn if DIR-UP snake-next-dir ! then endof
        [char] q of
          DIR-LEFT snake-can-turn if DIR-LEFT snake-next-dir ! then endof
        [char] s of
          DIR-DOWN snake-can-turn if DIR-DOWN snake-next-dir ! then endof
        [char] d of
          DIR-RIGHT snake-can-turn if DIR-RIGHT snake-next-dir ! then endof
        [char] w of
          DIR-UP snake-can-turn if DIR-UP snake-next-dir ! then endof
        [char] a of
          DIR-LEFT snake-can-turn if DIR-LEFT snake-next-dir ! then endof
        \ Flèches (codes spéciaux via scan code)
        72 of  \ flèche haut
          DIR-UP snake-can-turn if DIR-UP snake-next-dir ! then endof
        75 of  \ flèche gauche
          DIR-LEFT snake-can-turn if DIR-LEFT snake-next-dir ! then endof
        80 of  \ flèche bas
          DIR-DOWN snake-can-turn if DIR-DOWN snake-next-dir ! then endof
        77 of  \ flèche droite
          DIR-RIGHT snake-can-turn if DIR-RIGHT snake-next-dir ! then endof
        [char] p of
          GAME-PAUSE game-state !
        endof
        [char] r of
          snake-init
        endof
        drop
      endcase
    endof

    GAME-PAUSE of
      dup [char] p = over 32 = or if
        GAME-PLAY game-state !
      then
      [char] r = if snake-init then
    endof

    GAME-OVER of
      dup [char] r = over 32 = or if
        snake-init
      then
      drop
    endof

  endcase ;

\ ──────────────────────────────────────────────────────────────────────
\ 8. BOUCLE PRINCIPALE
\ ──────────────────────────────────────────────────────────────────────

variable snake-running
variable snake-last-tick
variable snake-exit-flag

: snake-step ( -- )
  \ Un pas de la boucle principale

  \ Traiter les touches en attente
  touche? dup 0 <> if
    dup 27 = if                 \ Échap → quitter
      drop 1 snake-exit-flag !
    else
      snake-handle-key
    then
  else
    drop
  then

  \ Avancer le jeu selon le timer
  ticks snake-last-tick @ - tick-speed @ >= if
    ticks snake-last-tick !
    snake-tick
  then

  \ Rendu
  snake-render ;

: snake ( -- )
  \ Point d'entrée principal du jeu
  cr ." === SNAKE — Epona OS ===" cr
  ." Controles: ZQSD ou WASD ou Fleches" cr
  ." P=Pause  R=Restart  Echap=Quitter" cr
  ." Espace pour commencer..." cr

  \ Initialisation
  0 best-score !
  0 snake-exit-flag !
  GAME-MENU game-state !
  0 snake-last-tick !

  \ Initialiser le RNG avec le temps actuel
  ticks rng-seed !

  \ Boucle principale
  begin
    snake-step
    16 ms                       \ ~60 fps

    snake-exit-flag @
  until

  \ Retour au terminal
  cr ." Score final : " score @ . cr
  ." Meilleur   : " best-score @ . cr
  ." A bientot !" cr ;

\ ──────────────────────────────────────────────────────────────────────
\ 9. MODE "PRINCIPAL" (pour F5 dans l'éditeur)
\ ──────────────────────────────────────────────────────────────────────

: principal ( -- )
  snake ;

\ ──────────────────────────────────────────────────────────────────────
\ 10. VARIANTE MULTITÂCHE (tâche de fond)
\ ──────────────────────────────────────────────────────────────────────
\
\ Lancer Snake comme tâche de fond (expérimental) :
\   ' snake task

\ ──────────────────────────────────────────────────────────────────────
\ CHARGEMENT TERMINÉ
\ ──────────────────────────────────────────────────────────────────────

cr
." ════════════════════════════════════════════════════════" cr
."  SNAKE.FTH charge avec succes" cr
."  Tapez 'snake' pour jouer" cr
."  Tapez 'principal' pour le mode editeur (F5)" cr
." ════════════════════════════════════════════════════════" cr