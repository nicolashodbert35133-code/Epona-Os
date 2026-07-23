( BUREAU.FTH — bureau graphique Epona OS 2.0 )
( Curseur souris + boutons reboot/poweroff )

( --- COULEURS --- )
0x1A1A2E constant C_FOND
0x2D2D44 constant C_BARRE
0x3D3D5C constant C_FENETRE
0x00FF00 constant C_VERT
0x00CC00 constant C_TITRE
0x444466 constant C_BORD
0xFF4444 constant C_ROUGE
0x4488FF constant C_BLEU
0xFFFFFF constant C_BLANC

( --- VARIABLES --- )
variable W variable H
variable BAR_Y
variable CX variable CY
variable MX variable MY variable MB
variable WX variable WY variable WW variable WH

( --- INIT --- )
gpu:init drop
gpu:resolution H ! W !
W @ 0 = H @ 0 = or if
  fb-size H ! W !
then
W @ H @ canvas-resize
H @ 40 - BAR_Y !
W @ 200 - 2 / WX !
H @ 300 - 2 / 80 max WY !
200 WW !
200 WH !

( --- CURSEUR EN CROIX --- )
: draw-cursor ( -- )
  souris MB ! MY ! CX !
  CX @ MY @ C_BLANC fb:pixel
  CX @ 1 + MY @ C_BLANC fb:pixel
  CX @ 2 + MY @ C_BLANC fb:pixel
  CX @ 3 + MY @ C_BLANC fb:pixel
  CX @ 4 + MY @ C_BLANC fb:pixel
  CX @ 5 + MY @ C_BLANC fb:pixel
  CX @ MY @ 1 + C_BLANC fb:pixel
  CX @ MY @ 2 + C_BLANC fb:pixel
  CX @ MY @ 3 + C_BLANC fb:pixel
  CX @ MY @ 4 + C_BLANC fb:pixel
  CX @ MY @ 5 + C_BLANC fb:pixel
  CX @ 1 + MY @ 1 + C_BLANC fb:pixel
  CX @ 2 + MY @ 2 + C_BLANC fb:pixel
  CX @ 3 + MY @ 3 + C_BLANC fb:pixel
  CX @ 4 + MY @ 4 + C_BLANC fb:pixel
;

( --- VERIFIER CLIC BOUTON REBOOT --- )
: check-reboot ( -- )
  souris MB ! MY ! CX !
  MB @ 1 =
  if
    CX @ W @ 280 - >=
    if
      CX @ W @ 200 - <=
      if
        MY @ BAR_Y @ 5 + >=
        if
          MY @ BAR_Y @ 35 + <=
          if reboot then
        then
      then
    then
  then
;

( --- VERIFIER CLIC BOUTON POWEROFF --- )
: check-poweroff ( -- )
  souris MB ! MY ! CX !
  MB @ 1 =
  if
    CX @ W @ 180 - >=
    if
      CX @ W @ 100 - <=
      if
        MY @ BAR_Y @ 5 + >=
        if
          MY @ BAR_Y @ 35 + <=
          if poweroff then
        then
      then
    then
  then
;

( --- BOUCLE PRINCIPALE --- )
: bureau ( -- )
  begin
    ( Fond )
    0 0 W @ H @ C_FOND fb:rect

    ( Barre des taches )
    0 BAR_Y @ W @ 40 C_BARRE fb:rect
    0 BAR_Y @ W @ 1 C_BORD fb:rect
    10 BAR_Y @ 10 + s" Epona OS 2.0" C_VERT 2 fb-text

    ( Bouton Reboot )
    W @ 280 - BAR_Y @ 5 + 80 30 C_BLEU fb:rect
    W @ 278 - BAR_Y @ 13 + s" Reboot" C_BLANC 1 fb-text

    ( Bouton Poweroff )
    W @ 180 - BAR_Y @ 5 + 80 30 C_ROUGE fb:rect
    W @ 178 - BAR_Y @ 13 + s" Off" C_BLANC 1 fb-text

    ( Fenetre )
    WX @ WY @ WW @ WH @ C_FENETRE fb:rect
    WX @ WY @ WW @ WH @ C_BORD rect-outline
    WX @ WY @ WW @ 30 C_TITRE fb:rect
    WX @ 5 + WY @ 5 + s" Terminal Forth" C_BLANC 2 fb-text

    ( Curseur )
    draw-cursor

    ( Verifier clics )
    check-reboot
    check-poweroff

    ( Afficher )
    fb-swap
    16 ms
  again
;

( --- LANCEMENT --- )
( Nécessaire : exec détecte ce mot comme point d'entrée )
bureau
