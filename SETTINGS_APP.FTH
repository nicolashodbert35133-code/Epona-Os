\ ============================================================
\ SETTINGS_APP.FTH  —  Paramètres système
\ ============================================================
\ Crée via : app: Config 420 40 200 250 settings-draw settings-key
\ ============================================================

variable _sx  variable _sy  variable _sw  variable _sh

: settings-draw ( wx wy ww wh -- )
  _sh ! _sw ! _sy ! _sx !

  \ Fond
  _sx @ _sy @ _sw @ _sh @ 0x16213E fb:rect

  \ Titre "CONFIG"
  _sx @ 8 + _sy @ 5 + 67 0xFFFFFF fb:text
  _sx @ 16 + _sy @ 5 + 79 0xFFFFFF fb:text
  _sx @ 24 + _sy @ 5 + 78 0xFFFFFF fb:text
  _sx @ 32 + _sy @ 5 + 70 0xFFFFFF fb:text
  _sx @ 40 + _sy @ 5 + 73 0xFFFFFF fb:text
  _sx @ 48 + _sy @ 5 + 70 0xFFFFFF fb:text

  \ Ligne
  _sx @ _sy @ 24 + _sx @ _sw @ + _sy @ 24 + FG fb:line

  \ Options (boutons simulés)
  \ "KB: AZERTY"
  _sx @ 8 + _sy @ 35 + 35 0xBBBBBB fb:text
  _sx @ 40 + _sy @ 35 + 43 0xBBBBBB fb:text
  _sx @ 8 + _sy @ 55 + _sw @ 16 - 20 0x444455 fb:rect
  _sx @ 12 + _sy @ 60 + 50 0x00CCFF fb:text
  _sx @ 12 + _sy @ 60 + 58 0x00CCFF fb:text
  _sx @ 12 + _sy @ 60 + 55 0x00CCFF fb:text
  _sx @ 12 + _sy @ 60 + 55 0x00CCFF fb:text

  \ "Vol: ---"
  _sx @ 8 + _sy @ 85 + 25 0xBBBBBB fb:text
  _sx @ 32 + _sy @ 85 + 45 0xBBBBBB fb:text
  _sx @ 32 + _sy @ 85 + 43 0xBBBBBB fb:text
  _sx @ 32 + _sy @ 85 + 44 0xBBBBBB fb:text

  \ Barre volume
  _sx @ 8 + _sy @ 105 + _sw @ 16 - 8 0x333344 fb:rect
  _sx @ 8 + _sy @ 105 + 60 8 0xE94560 fb:rect

  \ Info mémoire
  _sx @ 8 + _sy @ 130 + 55 0xBBBBBB fb:text
  _sx @ 16 + _sy @ 130 + 65 0xBBBBBB fb:text
  _sx @ 24 + _sy @ 130 + 77 0xBBBBBB fb:text

  \ Info CPU
  _sx @ 8 + _sy @ 150 + 40 0xBBBBBB fb:text
  _sx @ 16 + _sy @ 150 + 67 0xBBBBBB fb:text

  drop drop drop drop ;

: settings-key ( char -- ) drop ;
: settings-click ( x y -- ) 2drop ;
