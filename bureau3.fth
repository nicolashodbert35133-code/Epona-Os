( BUREAU.FTH — Bureau Epona OS 2.0 )
( Version sans locals — compatible strict )

( === COULEURS === )
0x0D1117 constant C_FOND
0x161B22 constant C_BARRE
0x21262D constant C_FENETRE
0x30363D constant C_BORD
0x3FB950 constant C_VERT
0x2EA043 constant C_TITRE
0xF85149 constant C_ROUGE
0x58A6FF constant C_BLEU
0x1F6FEB constant C_BLEU_H
0xFFFFFF constant C_BLANC
0x8B949E constant C_GRIS
0xFFAA00 constant C_ORANGE
0xD2A8FF constant C_VIOLET
0x484F58 constant C_BTN_X
0x1C2333 constant C_HOVER

( === VARIABLES === )
variable W
variable H
variable BAR_Y

variable MX
variable MY
variable MB
variable MB_PREV

variable CLK_H
variable CLK_M
variable CLK_S
create CLK_BUF 6 allot

variable TX
variable TY
variable TW
variable TH
variable T_VIS

variable IX
variable IY
variable IW
variable IH
variable I_VIS

variable FX
variable FY
variable FW
variable FH
variable F_VIS

variable T_DRAG
variable T_DX
variable T_DY

variable MENU_OPEN

variable RUNNING

( === INIT === )
: init-screen ( -- )
  fb-size H ! W !
  W @ H @ canvas-resize
  H @ 40 - BAR_Y !
  W @ 260 - 2 / TX !
  H @ 220 - 2 / 60 max TY !
  260 TW !
  200 TH !
  TX @ 40 + IX !
  TY @ 30 + IY !
  210 IW !
  170 IH !
  TX @ 80 + FX !
  TY @ 60 + FY !
  220 FW !
  180 FH !
  1 T_VIS !
  0 I_VIS !
  0 F_VIS !
  0 T_DRAG !
  0 MENU_OPEN !
  1 RUNNING !
  0 MB_PREV !
;

( === UTILITAIRES === )

( in-rect? : pile pure, pas de locals )
( px py rx ry rw rh -- flag )
: in-rect?
  >r >r >r >r
  ( px py  R: rh rw ry rx )
  over r> >=       ( px py  px>=rx  R: rh rw ry )
  over r> >=       ( px py  px>=rx  py>=ry  R: rh rw )
  and
  >r >r
  ( px py  R: and1 rw rh ... non, trop complexe )
  r> r>
  drop drop drop drop drop drop
  -1
;

( Simplifions : variables temporaires )
variable _PX
variable _PY
variable _RX
variable _RY
variable _RW
variable _RH

: in-rect? ( px py rx ry rw rh -- flag )
  _RH ! _RW ! _RY ! _RX ! _PY ! _PX !
  _PX @ _RX @ >=
  _PX @ _RX @ _RW @ + < and
  _PY @ _RY @ >= and
  _PY @ _RY @ _RH @ + < and
;

: mouse-read ( -- )
  MB @ MB_PREV !
  souris MB ! MY ! MX !
;

: just-clicked? ( -- flag )
  MB @ 1 = MB_PREV @ 0= and
;

: held? ( -- flag )
  MB @ 1 =
;

( === HORLOGE === )
: update-clock ( -- )
  get-time CLK_S ! CLK_M ! CLK_H !
  drop drop drop
;

: draw-clock ( -- )
  CLK_H @ 10 / 48 + CLK_BUF c!
  CLK_H @ 10 mod 48 + CLK_BUF 1 + c!
  58 CLK_BUF 2 + c!
  CLK_M @ 10 / 48 + CLK_BUF 3 + c!
  CLK_M @ 10 mod 48 + CLK_BUF 4 + c!
  0 CLK_BUF 5 + c!
  W @ 72 - BAR_Y @ 12 + CLK_BUF 5 C_BLANC 1 fb-text
;

( === CURSEUR === )
: draw-cursor ( -- )
  MX @ MY @ C_BLANC pixel
  MX @ MY @ 1 + C_BLANC pixel
  MX @ MY @ 2 + C_BLANC pixel
  MX @ MY @ 3 + C_BLANC pixel
  MX @ MY @ 4 + C_BLANC pixel
  MX @ MY @ 5 + C_BLANC pixel
  MX @ 1 + MY @ 1 + C_BLANC pixel
  MX @ 1 + MY @ 2 + C_BLANC pixel
  MX @ 2 + MY @ 3 + C_BLANC pixel
  MX @ 2 + MY @ 4 + C_BLANC pixel
  MX @ 3 + MY @ 5 + C_BLANC pixel
;

( === FOND === )
: draw-desktop ( -- )
  0 0 W @ H @ C_FOND rect
  W @ 170 - BAR_Y @ 24 - s" Epona OS 2.0" C_GRIS 1 fb-text
;

( === BARRE DES TACHES === )
: draw-taskbar ( -- )
  0 BAR_Y @ W @ 40 C_BARRE rect
  0 BAR_Y @ W @ 1 C_BORD rect

  ( Menu Epona )
  4 BAR_Y @ 4 + 92 32 C_BLEU rect
  14 BAR_Y @ 12 + s" Epona" C_BLANC 1 fb-text

  ( Term )
  102 BAR_Y @ 4 + 60 32
  T_VIS @ if C_TITRE else C_BORD then rect
  110 BAR_Y @ 12 + s" Term" C_BLANC 1 fb-text

  ( Info )
  168 BAR_Y @ 4 + 54 32
  I_VIS @ if C_TITRE else C_BORD then rect
  176 BAR_Y @ 12 + s" Info" C_BLANC 1 fb-text

  ( Fich )
  228 BAR_Y @ 4 + 54 32
  F_VIS @ if C_TITRE else C_BORD then rect
  236 BAR_Y @ 12 + s" Fich" C_BLANC 1 fb-text

  ( Quit )
  W @ 340 - BAR_Y @ 4 + 60 32 C_BORD rect
  W @ 328 - BAR_Y @ 12 + s" Quit" C_BLANC 1 fb-text

  ( Reboot )
  W @ 274 - BAR_Y @ 4 + 60 32 C_BLEU rect
  W @ 268 - BAR_Y @ 12 + s" Redo" C_BLANC 1 fb-text

  ( Off )
  W @ 208 - BAR_Y @ 4 + 50 32 C_ROUGE rect
  W @ 198 - BAR_Y @ 12 + s" Off" C_BLANC 1 fb-text

  ( Horloge )
  W @ 82 - BAR_Y @ 4 + 74 32 C_BORD rect
  draw-clock
;

( === MENU === )

variable MENU_Y

: calc-menu-y ( -- )
  BAR_Y @ 140 - MENU_Y !
;

: draw-menu ( -- )
  MENU_OPEN @ 0= if exit then
  calc-menu-y

  4 MENU_Y @ 156 140 C_FENETRE rect
  4 MENU_Y @ 156 140 C_BORD rect-outline

  14 MENU_Y @ 8 + s" Terminal" C_VERT 1 fb-text
  14 MENU_Y @ 36 + s" Infos" C_BLANC 1 fb-text
  14 MENU_Y @ 64 + s" Fichiers" C_ORANGE 1 fb-text
  14 MENU_Y @ 92 + s" Reboot" C_BLEU 1 fb-text
  14 MENU_Y @ 120 + s" Eteindre" C_ROUGE 1 fb-text
;

( === FENETRE TERMINAL === )
: draw-terminal ( -- )
  T_VIS @ 0= if exit then

  TX @ TY @ TW @ TH @ C_FENETRE rect
  TX @ TY @ TW @ TH @ C_BORD rect-outline

  ( Barre titre )
  TX @ 1 + TY @ 1 + TW @ 2 - 26 C_TITRE rect
  TX @ 6 + TY @ 7 + s" Terminal" C_BLANC 1 fb-text

  ( Bouton X )
  TX @ TW @ + 22 - TY @ 4 + 18 18 C_BTN_X rect
  TX @ TW @ + 16 - TY @ 8 + s" X" C_BLANC 1 fb-text

  ( Contenu )
  TX @ 8 + TY @ 36 + s" Epona Forth v2.0" C_VERT 1 fb-text
  TX @ 8 + TY @ 54 + s" > words" C_VERT 1 fb-text
  TX @ 8 + TY @ 70 + s" dup drop swap" C_BLANC 1 fb-text
  TX @ 8 + TY @ 86 + s" + - * / mod" C_BLANC 1 fb-text
  TX @ 8 + TY @ 110 + s" > _" C_VERT 1 fb-text
;

( === FENETRE INFO === )
: draw-info ( -- )
  I_VIS @ 0= if exit then

  IX @ IY @ IW @ IH @ C_FENETRE rect
  IX @ IY @ IW @ IH @ C_BORD rect-outline

  IX @ 1 + IY @ 1 + IW @ 2 - 26 C_BLEU rect
  IX @ 6 + IY @ 7 + s" Infos" C_BLANC 1 fb-text

  IX @ IW @ + 22 - IY @ 4 + 18 18 C_BTN_X rect
  IX @ IW @ + 16 - IY @ 8 + s" X" C_BLANC 1 fb-text

  IX @ 8 + IY @ 36 + s" Epona OS 2.0" C_BLANC 1 fb-text
  IX @ 8 + IY @ 54 + s" Forth bare-metal" C_VERT 1 fb-text
  IX @ 8 + IY @ 72 + s" UEFI x86-64" C_VERT 1 fb-text
  IX @ 8 + IY @ 90 + s" JIT natif" C_VERT 1 fb-text
  IX @ 8 + IY @ 108 + s" USB 3 + NVMe" C_VERT 1 fb-text
  IX @ 8 + IY @ 126 + s" TCP/IP + HDA" C_VERT 1 fb-text
;

( === FENETRE FICHIERS === )
: draw-files ( -- )
  F_VIS @ 0= if exit then

  FX @ FY @ FW @ FH @ C_FENETRE rect
  FX @ FY @ FW @ FH @ C_BORD rect-outline

  FX @ 1 + FY @ 1 + FW @ 2 - 26 C_ORANGE rect
  FX @ 6 + FY @ 7 + s" Fichiers" C_BLANC 1 fb-text

  FX @ FW @ + 22 - FY @ 4 + 18 18 C_BTN_X rect
  FX @ FW @ + 16 - FY @ 8 + s" X" C_BLANC 1 fb-text

  FX @ 8 + FY @ 36 + s" BOOT.FTH" C_BLANC 1 fb-text
  FX @ 8 + FY @ 54 + s" BUREAU.FTH" C_BLEU 1 fb-text
  FX @ 8 + FY @ 72 + s" BOOT.JIT" C_VIOLET 1 fb-text
  FX @ 8 + FY @ 90 + s" EPONAKEY.DAT" C_ROUGE 1 fb-text
  FX @ 8 + FY @ 108 + s" PCI.TXT" C_GRIS 1 fb-text
  FX @ 8 + FY @ 126 + s" ACPI.TXT" C_GRIS 1 fb-text
;

( === DRAG TERMINAL === )
: handle-drag ( -- )
  held? if
    T_DRAG @ if
      MX @ T_DX @ - TX !
      MY @ T_DY @ - TY !
    else
      T_VIS @ if
        MX @ MY @ TX @ TY @ TW @ 26 in-rect? if
          MX @ TX @ TW @ + 22 - < if
            1 T_DRAG !
            MX @ TX @ - T_DX !
            MY @ TY @ - T_DY !
          then
        then
      then
    then
  else
    0 T_DRAG !
  then
;

( === CLICS === )
: handle-clicks ( -- )
  just-clicked? 0= if exit then

  ( Menu Epona )
  MX @ MY @ 4 BAR_Y @ 4 + 92 32 in-rect? if
    MENU_OPEN @ if 0 else 1 then MENU_OPEN !
    exit
  then

  MENU_OPEN @ if
    calc-menu-y

    MX @ MY @ 4 MENU_Y @ 156 28 in-rect? if
      T_VIS @ if 0 else 1 then T_VIS !
      0 MENU_OPEN ! exit
    then

    MX @ MY @ 4 MENU_Y @ 28 + 156 28 in-rect? if
      I_VIS @ if 0 else 1 then I_VIS !
      0 MENU_OPEN ! exit
    then

    MX @ MY @ 4 MENU_Y @ 56 + 156 28 in-rect? if
      F_VIS @ if 0 else 1 then F_VIS !
      0 MENU_OPEN ! exit
    then

    MX @ MY @ 4 MENU_Y @ 84 + 156 28 in-rect? if
      0 MENU_OPEN ! reboot
    then

    MX @ MY @ 4 MENU_Y @ 112 + 156 28 in-rect? if
      0 MENU_OPEN ! poweroff
    then

    0 MENU_OPEN !
    exit
  then

  ( Barre : Term )
  MX @ MY @ 102 BAR_Y @ 4 + 60 32 in-rect? if
    T_VIS @ if 0 else 1 then T_VIS ! exit
  then

  ( Barre : Info )
  MX @ MY @ 168 BAR_Y @ 4 + 54 32 in-rect? if
    I_VIS @ if 0 else 1 then I_VIS ! exit
  then

  ( Barre : Fich )
  MX @ MY @ 228 BAR_Y @ 4 + 54 32 in-rect? if
    F_VIS @ if 0 else 1 then F_VIS ! exit
  then

  ( Quit )
  MX @ MY @ W @ 340 - BAR_Y @ 4 + 60 32 in-rect? if
    0 RUNNING ! exit
  then

  ( Reboot )
  MX @ MY @ W @ 274 - BAR_Y @ 4 + 60 32 in-rect? if
    reboot
  then

  ( Off )
  MX @ MY @ W @ 208 - BAR_Y @ 4 + 50 32 in-rect? if
    poweroff
  then

  ( Bouton X Terminal )
  T_VIS @ if
    MX @ MY @ TX @ TW @ + 22 - TY @ 4 + 18 18 in-rect? if
      0 T_VIS ! exit
    then
  then

  ( Bouton X Info )
  I_VIS @ if
    MX @ MY @ IX @ IW @ + 22 - IY @ 4 + 18 18 in-rect? if
      0 I_VIS ! exit
    then
  then

  ( Bouton X Fichiers )
  F_VIS @ if
    MX @ MY @ FX @ FW @ + 22 - FY @ 4 + 18 18 in-rect? if
      0 F_VIS ! exit
    then
  then
;

( === BOUCLE PRINCIPALE === )
: bureau ( -- )
  init-screen
  begin
    mouse-read
    update-clock

    draw-desktop
    draw-files
    draw-info
    draw-terminal
    draw-taskbar
    draw-menu
    draw-cursor

    handle-drag
    handle-clicks

    fb-swap
    16 ms

    RUNNING @ 0=
  until
;

bureau